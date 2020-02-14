//
//  RFProgressButton.swift
//  RFRoundedProgressButton
//
//  Created by Raffaele Forgione on 14/02/2020.
//  Copyright © 2020 Raffaele Forgione. All rights reserved.
//

import UIKit

class RFProgressButton: UIButton {
    
    
    @IBInspectable var backColor: UIColor = .white
    @IBInspectable var progressColor: UIColor = .blue
    @IBInspectable var borderWidth: CGFloat = 2
    
    var forcedUserInteractionDisabled = false
    private var isCreating = true
    private var timedout = false
    private var completed = false
    private var fgCompletionHandler: (() -> Void) = {}
    private var bgCompletionHandler: (() -> Void) = {}
    private var timer: Timer?
    private var borderLength: CGFloat = 0.0
    private var totalSeconds: CGFloat = 0.0
    private var deltaProgress: CGFloat = 0.0
    private var bgProgress: CGFloat = 0.0
    private var currentProgress: CGFloat = 0.0
    private var timerFireInterval: CGFloat = 0.0
    private var frontLayer: CAShapeLayer?
    private var backLayer: CAShapeLayer?
    private var startTimeStamp: TimeInterval = 0.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isCreating = true
        NotificationCenter.default.addObserver(self, selector: #selector(fromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopProgress()
    }

    override func draw(_ rect: CGRect) {
        if isCreating {
            isCreating = false
            forcedUserInteractionDisabled = false
            layer.cornerRadius = rect.size.height / 2
            borderLength = 2 * ((frame.size.width - layer.cornerRadius) + .pi * layer.cornerRadius)
            layer.masksToBounds = true
            drawInitialPath()
        }
    }
    
    private func drawInitialPath() {
        backLayer = initialShape()
        frontLayer = initialShape()

        backLayer?.strokeColor = backColor.cgColor
        frontLayer?.strokeColor = progressColor.cgColor

        layer.addSublayer(backLayer!)
        layer.addSublayer(frontLayer!)
    }

    private func drawFilledPath() {
        clearLayers()
        frontLayer = initialShape()

        frontLayer?.strokeColor = progressColor.cgColor
        frontLayer?.fillColor = progressColor.cgColor

        layer.insertSublayer(frontLayer!, below: titleLabel?.layer)
    }
    
    private func initialShape() -> CAShapeLayer? {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: frame.size.width - layer.cornerRadius, y: 0))
        path.addArc(withCenter: CGPoint(x: frame.size.width - layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: .pi * 3 / 2, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: layer.cornerRadius, y: frame.size.height))
        path.addArc(withCenter: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: .pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
        path.close()

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = borderWidth
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }
    
    private func redrawShape(withProgress progress: CGFloat) {
        let path = UIBezierPath()
        let firstLineWidth = CGFloat(frame.size.width / 2 - layer.cornerRadius)
        
        if progress < firstLineWidth {
            path.move(to: CGPoint(x: frame.size.width / 2 + progress, y: 0))
            path.addLine(to: CGPoint(x: frame.size.width / 2 + firstLineWidth, y: 0))
            // parte successiva
            
            path.addArc(withCenter: CGPoint(x: frame.size.width - layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: .pi * 3 / 2, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: layer.cornerRadius / 2, y: frame.size.height))
            path.addArc(withCenter: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: .pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
            path.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
        }
        else if progress < firstLineWidth + .pi * layer.cornerRadius {
            let areaLength = CGFloat(.pi * layer.cornerRadius)
            let progressInArea: CGFloat = progress - firstLineWidth
            let inc: CGFloat = progressInArea / areaLength
            let piProgress = .pi * inc - .pi / 2
            path.addArc(withCenter: CGPoint(x: frame.size.width - layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: CGFloat(piProgress), endAngle: .pi / 2, clockwise: true)
            // parte successiva
            path.addLine(to: CGPoint(x: layer.cornerRadius, y: frame.size.height))
            path.addArc(withCenter: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: .pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
            path.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
        }
        else if progress < 3 * firstLineWidth + .pi * layer.cornerRadius {
            let tempProgress = progress - (firstLineWidth + .pi * layer.cornerRadius)
            path.move(to: CGPoint(x: frame.size.width - layer.cornerRadius - CGFloat(tempProgress), y: frame.size.height))
            path.addLine(to: CGPoint(x: layer.cornerRadius, y: frame.size.height))
            path.addArc(withCenter: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: .pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
            path.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
        }
        else if progress < 2 * (.pi * layer.cornerRadius) + 3 * firstLineWidth {
            let areaLength = CGFloat((.pi * layer.cornerRadius))
            let totalProgress = 2 * areaLength + 3 * firstLineWidth
            let progressInArea = progress - (totalProgress - areaLength)
            let inc = progressInArea / areaLength
            let piProgress = (.pi / 2) + .pi * inc
            path.addArc(withCenter: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), radius: layer.cornerRadius, startAngle: CGFloat(piProgress), endAngle: .pi * 3 / 2, clockwise: true)
            path.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
        }
        else {
            let tempProgress = CGFloat(progress - (3 * firstLineWidth + 2 * (.pi * layer.cornerRadius)))
            if tempProgress > firstLineWidth {
                completed = true
                return
            }
            else {
                path.move(to: CGPoint(x: layer.cornerRadius + tempProgress, y: 0))
                path.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
            }
        }
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = borderWidth
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = progressColor.cgColor

        frontLayer?.removeFromSuperlayer()
        frontLayer = layer
        self.layer.addSublayer(frontLayer!)
        
    }

    final func startCountDown(withSeconds seconds: CGFloat, withForegroundCompletion fgCompletion: @escaping () -> Void, andBackgroundCompletion bgCompletion: @escaping () -> Void) {
        timedout = false
        completed = false
        bgProgress = 0
        currentProgress = 0
        deltaProgress = borderLength / 1000
        totalSeconds = seconds
        timerFireInterval = seconds * deltaProgress / borderLength
        fgCompletionHandler = fgCompletion
        bgCompletionHandler = bgCompletion
        startTimeStamp = Date().timeIntervalSince1970
        animate(withProgress: 0, time: timerFireInterval, withForegroundCompletion: fgCompletion, andBackgroundCompletion: bgCompletion)
    }
    
    final func startCountDown(withSeconds seconds: CGFloat, delay: CGFloat, withForegroundCompletion fgCompletion: @escaping () -> Void, andBackgroundCompletion bgCompletion: @escaping () -> Void) {
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(delay) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [unowned self] in
            if self.forcedUserInteractionDisabled {
                self.isUserInteractionEnabled = true
            }
            self.startCountDown(withSeconds: seconds, withForegroundCompletion: fgCompletion, andBackgroundCompletion: bgCompletion)
        })
    }
    
    final func resumeProgress() {
        animate(withProgress: currentProgress, time: timerFireInterval, withForegroundCompletion: fgCompletionHandler, andBackgroundCompletion: bgCompletionHandler)
    }

    final func restartCountDown(withSeconds seconds: CGFloat, withForegroundCompletion fgCompletion: @escaping () -> Void, andBackgroundCompletion bgCompletion: @escaping () -> Void) {
        redraw()
        fgCompletionHandler = fgCompletion
        bgCompletionHandler = bgCompletion
        startCountDown(withSeconds: seconds, withForegroundCompletion: fgCompletion, andBackgroundCompletion: bgCompletion)
    }
    
    final func restartCountDown(withSeconds seconds: CGFloat, delay: CGFloat, withForegroundCompletion fgCompletion: @escaping () -> Void, andBackgroundCompletion bgCompletion: @escaping () -> Void) {
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(delay) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [unowned self] in
            if self.forcedUserInteractionDisabled {
                self.isUserInteractionEnabled = true
            }
            self.restartCountDown(withSeconds: seconds, withForegroundCompletion: fgCompletion, andBackgroundCompletion: bgCompletion)
        })
    }

    private func redraw() {
        clearLayers()
        drawInitialPath()
    }

    private func clearLayers() {
        frontLayer?.removeFromSuperlayer()
        backLayer?.removeFromSuperlayer()
    }
    
    private func animate(withProgress progress: CGFloat, time: CGFloat, withForegroundCompletion fgCompletion: @escaping () -> Void, andBackgroundCompletion bgCompletion: @escaping () -> Void) {
        DispatchQueue.main.async(execute: { [unowned self] in
            self.redrawShape(withProgress: progress)
        })
        
        shouldManageBackground(withProgress: progress, time: time, withForegroundCompletion: fgCompletion, andBackgroundCompletion: bgCompletion)
    }
    
    private func stop(with completion: () -> ()) {
        stopProgress()
        DispatchQueue.main.async(execute: { [unowned self] in
            self.redrawShape(withProgress: self.borderLength)
        })
        completion()
    }
    
    private func shouldManageBackground(withProgress progress: CGFloat, time: CGFloat, withForegroundCompletion fgCompletion: @escaping () -> Void, andBackgroundCompletion bgCompletion: @escaping () -> Void) {
        var progress = progress
        if timedout {
            timedout = false
            stop {
                bgCompletion()
            }
        }
        else if completed {
            completed = false
            stop {
                fgCompletion()
            }
        }
        else {
            var nextProgress: CGFloat = progress + deltaProgress
            let currentProgress = progress
            if bgProgress > 0 {
                nextProgress = bgProgress
                progress = nextProgress - deltaProgress
                bgProgress = 0
            }
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time), repeats: false, block: { [unowned self] timer in
                self.currentProgress = currentProgress
                self.animate(withProgress: nextProgress, time: time, withForegroundCompletion: fgCompletion, andBackgroundCompletion: bgCompletion)
            })
        }
    }
    
    @objc private func fromBackground() {
        //    printf("CURRENT TIMESTAMP: %lf", currentTimeStamp);
        //    printf("START TIMESTAMP: %lf", _startTimeStamp);
        let currentTimeStamp = Date().timeIntervalSince1970
        let deltaTimestamp = currentTimeStamp - startTimeStamp
        if deltaTimestamp >= Double(totalSeconds) {
            timedout = true
        }
        bgProgress = borderLength * CGFloat(deltaTimestamp) / totalSeconds
    }

    final func stopProgress() {
        timer?.invalidate()
        timer = nil
    }

}
