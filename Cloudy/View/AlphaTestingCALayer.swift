// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

class AlphaTestingCALayer: CALayer {

    override func contains(_ p: CGPoint) -> Bool {
        bounds.contains(p) && alphaAt(point: p) > 0.001
    }

    func alphaAt(point: CGPoint) -> CGFloat {
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        let colorSpace             = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo             = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context                = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y)
        render(in: context!)
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0
        return alpha
    }

}
