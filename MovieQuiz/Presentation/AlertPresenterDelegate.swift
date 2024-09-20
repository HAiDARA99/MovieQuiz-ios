import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func show(model: AlertModel)
}

