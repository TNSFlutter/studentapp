# frozen_string_literal: true

# Patches razorpay_flutter in the local pub-cache (fixes crash after successful payment).
# - iOS: nil `data` in success callback → Dart plugin did `data!` → crash; merge `payment_id`.
# - Dart: null-safe `_handleResult` for all payment event types.
#
# Run automatically from ios/Podfile `pre_install`, or manually:
#   ruby tool/patch_razorpay_pub_cache.rb

def apply_razorpay_pub_cache_patches!
  cache = ENV['PUB_CACHE'] || File.join(Dir.home, '.pub-cache')
  hosted = File.join(cache, 'hosted', 'pub.dev')
  return unless File.directory?(hosted)

  Dir.glob(File.join(hosted, 'razorpay_flutter-*', 'ios', 'Classes', 'RazorpayDelegate.swift')).each do |path|
    patch_razorpay_ios_delegate!(path)
  end

  Dir.glob(File.join(hosted, 'razorpay_flutter-*', 'lib', 'razorpay_flutter.dart')).each do |path|
    patch_razorpay_dart_plugin!(path)
  end
end

def patch_razorpay_ios_delegate!(path)
  orig = File.read(path)
  s = orig.dup

  unless s.include?('Patched: subscribeToAnalyticsEvents')
    if s.include?('subscribeToAnalyticsEvents(events, callback: self)')
      s = s.sub(
        %r{        if let events = subscribedAnalyticsEvents, !events.isEmpty \{\n            razorpay\.subscribeToAnalyticsEvents\(events, callback: self\)\n        \}},
        "        // Patched: subscribeToAnalyticsEvents (Razorpay iOS SDK mismatch)\n" \
        "        // if let events = subscribedAnalyticsEvents, !events.isEmpty {\n" \
        "        //     razorpay.subscribeToAnalyticsEvents(events, callback: self)\n" \
        "        // }",
      )
    end
  end

  # Anchor on CODE_PAYMENT_SUCCESS — `response["data"] = data` also appears in
  # onExternalWalletSelected (local var `data`) and must not be matched.
  unless s.include?('Patched: Flutter null-safe payment success payload')
    ind = '        '
    repl_body = [
      "#{ind}// Patched: Flutter null-safe payment success payload (nil data crashes Dart plugin)",
      "#{ind}var merged: [String: Any] = [:]",
      "#{ind}if let d = data {",
      "#{ind}    for (k, v) in d {",
      "#{ind}        if let key = k as? String {",
      "#{ind}            merged[key] = v",
      "#{ind}        }",
      "#{ind}    }",
      "#{ind}}",
      "#{ind}if merged[\"razorpay_payment_id\"] == nil {",
      "#{ind}    merged[\"razorpay_payment_id\"] = payment_id",
      "#{ind}}",
      "#{ind}response[\"data\"] = merged",
    ].join("\n")
    ns = s.sub(
      /(response\["type"\] = RazorpayDelegate\.CODE_PAYMENT_SUCCESS\s*\n)response\["data"\] = data\s*\n\s*pendingResult\(response as NSDictionary\)/m,
    ) do
      "#{Regexp.last_match(1)}#{repl_body}\n\n#{ind}pendingResult(response as NSDictionary)"
    end
    s = ns if ns != s
  end

  return if s == orig

  File.write(path, s)
rescue Errno::EPERM, Errno::EACCES => e
  warn "Razorpay iOS patch skipped (no write access to pub-cache): #{path} (#{e.class})"
end

def patch_razorpay_dart_plugin!(path)
  orig = File.read(path)
  return if orig.include?('Patched: null-safe _handleResult data')

  d = orig.dup
  d = d.gsub(
    'payload = PaymentSuccessResponse.fromMap(data!);',
    'payload = PaymentSuccessResponse.fromMap(' \
    'data is Map ? Map<dynamic, dynamic>.from(data as Map) : <dynamic, dynamic>{}); ' \
    '// Patched: null-safe _handleResult data',
  )
  d = d.gsub(
    'payload = PaymentFailureResponse.fromMap(data!);',
    'payload = PaymentFailureResponse.fromMap(' \
    'data is Map ? Map<dynamic, dynamic>.from(data as Map) : <dynamic, dynamic>{}); ' \
    '// Patched: null-safe _handleResult data',
  )
  d = d.gsub(
    'payload = ExternalWalletResponse.fromMap(data!);',
    'payload = ExternalWalletResponse.fromMap(' \
    'data is Map ? Map<dynamic, dynamic>.from(data as Map) : <dynamic, dynamic>{}); ' \
    '// Patched: null-safe _handleResult data',
  )
  return if d == orig

  File.write(path, d)
rescue Errno::EPERM, Errno::EACCES => e
  warn "Razorpay Dart patch skipped (no write access to pub-cache): #{path} (#{e.class})"
end

apply_razorpay_pub_cache_patches! if __FILE__ == $0
