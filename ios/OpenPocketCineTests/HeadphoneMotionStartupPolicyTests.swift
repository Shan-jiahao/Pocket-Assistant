import XCTest

@testable import OpenPocketCine

final class HeadphoneMotionStartupPolicyTests: XCTestCase {
    func testRestartsWhenActiveStreamProducesNoFirstSample() {
        XCTAssertTrue(
            HeadphoneMotionStartupPolicy.shouldRestart(
                startedAt: 10,
                now: 10 + HeadphoneMotionStartupPolicy.firstSampleTimeout,
                hasSample: false,
                restartCount: 0
            ))
    }

    func testDoesNotRestartBeforeFirstSampleTimeout() {
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldRestart(
                startedAt: 10,
                now: 10 + HeadphoneMotionStartupPolicy.firstSampleTimeout - 0.01,
                hasSample: false,
                restartCount: 0
            ))
    }

    func testDoesNotRestartAfterSampleArrives() {
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldRestart(
                startedAt: 10,
                now: 20,
                hasSample: true,
                restartCount: 0
            ))
    }

    func testAutomaticRestartsAreBounded() {
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldRestart(
                startedAt: 10,
                now: 20,
                hasSample: false,
                restartCount: HeadphoneMotionStartupPolicy.maxAutomaticRestarts
            ))
    }

    func testPullFallbackStartsAfterPushRestartsAreExhausted() {
        XCTAssertTrue(
            HeadphoneMotionStartupPolicy.shouldUsePullFallback(
                hasSample: false,
                restartCount: HeadphoneMotionStartupPolicy.maxAutomaticRestarts,
                alreadyUsingFallback: false
            ))
    }

    func testPullFallbackIsNotStartedTwice() {
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldUsePullFallback(
                hasSample: false,
                restartCount: HeadphoneMotionStartupPolicy.maxAutomaticRestarts,
                alreadyUsingFallback: true
            ))
    }

    func testProvisionalDisconnectIsConfirmedWhenNoNewConnectionEventArrives() {
        XCTAssertTrue(
            HeadphoneMotionStartupPolicy.shouldConfirmDisconnect(
                generation: 4, currentGeneration: 4, motionDesired: true))
    }

    func testProvisionalDisconnectIsCancelledByReconnect() {
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldConfirmDisconnect(
                generation: 4, currentGeneration: 5, motionDesired: true))
    }

    func testLifecycleStopSuppressesLateDisconnectCallback() {
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldConfirmDisconnect(
                generation: 4, currentGeneration: 4, motionDesired: false))
    }

    func testMotionStartIsSerializedUntilFirstRequestSettles() {
        XCTAssertTrue(
            HeadphoneMotionStartupPolicy.shouldBeginMotion(
                motionDesired: true, isActive: false, startRequested: false))
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldBeginMotion(
                motionDesired: true, isActive: false, startRequested: true))
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldBeginMotion(
                motionDesired: true, isActive: true, startRequested: false))
        XCTAssertFalse(
            HeadphoneMotionStartupPolicy.shouldBeginMotion(
                motionDesired: false, isActive: false, startRequested: false))
    }
}
