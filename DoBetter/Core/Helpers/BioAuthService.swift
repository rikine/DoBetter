//
// Created by Никита Шестаков on 08.03.2023.
//

import Foundation
import UIKit
import LocalAuthentication

final class BioAuthService: NSObject {
    // MARK: - Singleton
    public static let shared = BioAuthService()
}

extension BioAuthService {

    /// checks if TouchID or FaceID is available on the device.
    func canAuthenticate() -> Bool {
        var isBiometricAuthenticationAvailable = false
        var error: NSError? = nil

        if LAContext().canEvaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) {
            isBiometricAuthenticationAvailable = (error == nil)
        }
        return isBiometricAuthenticationAvailable
    }

    /// Check for biometric authentication
    func authenticateWithBioMetrics(reason: String, fallbackTitle: String? = "",
                                    cancelTitle: String? = "",
                                    success successBlock: @escaping AuthenticationSuccess,
                                    failure failureBlock: @escaping AuthenticationFailure) {
        let reasonString = reason.isEmpty
            ? BioAuthService.shared.defaultBiometricAuthenticationReason()
            : reason

        let context = LAContext()
        context.localizedFallbackTitle = fallbackTitle
        context.localizedCancelTitle = cancelTitle
        BioAuthService.shared.evaluate(policy: .deviceOwnerAuthenticationWithBiometrics,
                                       with: context,
                                       reason: reasonString,
                                       success: successBlock,
                                       failure: failureBlock)
    }

    /// Check for device passcode authentication
    func authenticateWithPasscode(reason: String, cancelTitle: String? = "",
                                  success successBlock: @escaping AuthenticationSuccess,
                                  failure failureBlock: @escaping AuthenticationFailure) {
        let reasonString = reason.isEmpty
            ? BioAuthService.shared.defaultPasscodeAuthenticationReason()
            : reason

        let context = LAContext()
        context.localizedCancelTitle = cancelTitle
        BioAuthService.shared.evaluate(policy: .deviceOwnerAuthentication,
                                       with: context,
                                       reason: reasonString,
                                       success: successBlock,
                                       failure: failureBlock)
    }

    /// checks if face id is available on device
    func faceIDAvailable() -> Bool {
        let context = LAContext()
        return (context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: nil
        ) && context.biometryType == .faceID)
    }
}

private extension BioAuthService {
    /// get authentication reason to show while authentication
    func defaultBiometricAuthenticationReason() -> String {
        faceIDAvailable() ? kFaceIdAuthenticationReason : kTouchIdAuthenticationReason
    }

    /// get passcode authentication reason to show while entering device passcode after multiple failed attempts
    func defaultPasscodeAuthenticationReason() -> String {
        faceIDAvailable() ? kFaceIdPasscodeAuthenticationReason : kTouchIdPasscodeAuthenticationReason
    }

    /// evaluate policy
    func evaluate(policy: LAPolicy, with context: LAContext, reason: String, success successBlock: @escaping AuthenticationSuccess, failure failureBlock: @escaping AuthenticationFailure) {
        context.evaluatePolicy(policy, localizedReason: reason) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                    successBlock()
                } else {
                    failureBlock((error as? LAError).map(AuthenticationError.from) ?? .canceledBySystem)
                }
            }
        }
    }
}

/// Authentication Errors
public enum AuthenticationError {
    case failed, canceledByUser, fallback, canceledBySystem, passcodeNotSet, biometryNotEnrolled, biometryLockedout, notAvailable, other

    public static func from(error: LAError) -> AuthenticationError {
        switch Int32(error.errorCode) {
        case kLAErrorAuthenticationFailed:
            return failed
        case kLAErrorUserCancel:
            return canceledByUser
        case kLAErrorUserFallback:
            return fallback
        case kLAErrorSystemCancel:
            return canceledBySystem
        case kLAErrorPasscodeNotSet:
            return passcodeNotSet
        case kLAErrorBiometryNotEnrolled:
            return biometryNotEnrolled
        case kLAErrorBiometryLockout:
            return biometryLockedout
        case kLAErrorBiometryNotAvailable:
            return notAvailable
        default:
            return other
        }
    }

    // get error message based on type
    public func message() -> String {
        let authentication = BioAuthService.shared

        switch self {
        case .canceledByUser, .fallback, .canceledBySystem:
            return ""
        case .passcodeNotSet:
            return authentication.faceIDAvailable() ? kSetPasscodeToUseFaceID : kSetPasscodeToUseTouchID
        case .biometryNotEnrolled:
            return authentication.faceIDAvailable() ? kNoFaceIdentityEnrolled : kNoFingerprintEnrolled
        case .biometryLockedout:
            return authentication.faceIDAvailable() ? kFaceIdPasscodeAuthenticationReason : kTouchIdPasscodeAuthenticationReason
        default:
            return authentication.faceIDAvailable() ? kDefaultFaceIDAuthenticationFailedReason : kDefaultTouchIDAuthenticationFailedReason
        }
    }
}

// success block
public typealias AuthenticationSuccess = () -> ()

/// failure block
public typealias AuthenticationFailure = (AuthenticationError) -> ()

private typealias Strings = Localization.BioAuth

/// ****************  Touch ID  ****************** ///
private let kTouchIdAuthenticationReason = Strings.kTouchIdAuthenticationReason.localized
private let kTouchIdPasscodeAuthenticationReason = Strings.kTouchIdPasscodeAuthenticationReason.localized

/// Error Messages Touch ID
private let kSetPasscodeToUseTouchID = Strings.kSetPasscodeToUseTouchID.localized
private let kNoFingerprintEnrolled = Strings.kNoFingerprintEnrolled.localized
private let kDefaultTouchIDAuthenticationFailedReason = Strings.kDefaultTouchIDAuthenticationFailedReason.localized

/// ****************  Face ID  ****************** ///
private let kFaceIdAuthenticationReason = Strings.kFaceIdAuthenticationReason.localized
private let kFaceIdPasscodeAuthenticationReason = Strings.kFaceIdPasscodeAuthenticationReason.localized

/// Error Messages Face ID
private let kSetPasscodeToUseFaceID = Strings.kSetPasscodeToUseFaceID.localized
private let kNoFaceIdentityEnrolled = Strings.kNoFaceIdentityEnrolled.localized
private let kDefaultFaceIDAuthenticationFailedReason = Strings.kDefaultFaceIDAuthenticationFailedReason.localized
