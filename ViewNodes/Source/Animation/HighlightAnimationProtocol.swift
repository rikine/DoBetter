//  HighlightAnimationProtocol.swift
//  Created by Vladimir Roganov on 18.03.2022.

import UIKit

/// Применяется для микроанимаций, которые не нуждаются в синхронизации/интерполяции
/// Прим.: короткий фидбек при тапе
/// В данный момент реализацию можно найти в `HighlightAnimation.swift` с несколькими базовыми вариантами анимаций
/// Используется в классе `View`, поэтому при желании можно легко задействовать практически по всему приложению
/// Пример использования: `someView.highlightAnimation = HighlightAnimation.scaleTouch` - выдаст уменьшение на `.touchBegan`, и возврат к прежнему размеру на `.touchCanceled || .touchEnded`
/// Сам протокол добавлен чтобы можно было создать разные варианты анимаций у которых могут быть разные параметры, например `HighlightAnimationComposition: HighlightAnimationProtocol`, который обединяет два экзепляра `HighlightAnimationProtocol` вместо того, чтобы брать на входе какие-либо параметры анимации
public protocol HighlightAnimationProtocol {
    func animate(isHighlighted: Bool, view: UIView)
}
