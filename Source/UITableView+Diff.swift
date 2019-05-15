//
//  UITableView+Diff.swift
//  HeckelDiff
//
//  Created by Matias Cudich on 11/23/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import UIKit

public struct DiffAnimation {
    let insertAnimation: UITableView.RowAnimation
    let deleteAnimation: UITableView.RowAnimation
    let reloadAnimation: UITableView.RowAnimation
    let disabledReloadAnimationIndexPaths: [IndexPath]

    public init(insertAnimation: UITableView.RowAnimation,
                deleteAnimation: UITableView.RowAnimation,
                reloadAnimation: UITableView.RowAnimation,
                disabledReloadAnimationIndexPaths: [IndexPath]) {

        self.insertAnimation = insertAnimation
        self.deleteAnimation = deleteAnimation
        self.reloadAnimation = reloadAnimation
        self.disabledReloadAnimationIndexPaths = disabledReloadAnimationIndexPaths
    }
}

public extension UITableView {
    /// Applies a batch update to the receiver, efficiently reporting changes between old and new.
    ///
    /// - parameter old:       The previous state of the table view.
    /// - parameter new:       The current state of the table view.
    /// - parameter section:   The section where these changes took place.
    /// - parameter diffAnimation: The animation config for updating content.
    func applyDiff<T: Collection>(_ old: T, _ new: T, inSection section: Int,
                                  withDiffAnimation diffAnimation: DiffAnimation,
                                  reloadVisible: Bool = false,
                                  completion: @escaping () -> Void)
        where T.Iterator.Element: Hashable, T.Index == Int {

            let update = ListUpdate(diff(old, new), section)

            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)

            beginUpdates()
            deleteRows(at: update.deletions, with: diffAnimation.deleteAnimation)
            insertRows(at: update.insertions, with: diffAnimation.insertAnimation)
            for move in update.moves {
                moveRow(at: move.from, to: move.to)
            }
            endUpdates()

            // reloadItems is done separately as the update indexes returned by diff() are in respect to the
            // "after" state, but the collectionView.reloadItems() call wants the "before" indexPaths.
            if !update.updates.isEmpty || reloadVisible {
                var rows = update.updates
                if reloadVisible {
                    rows += (indexPathsForVisibleRows ?? [])
                }
                let rowsWithAnimation = rows.filter { !diffAnimation.disabledReloadAnimationIndexPaths.contains($0) }
                let rowsWithoutAnimation = rows.filter { diffAnimation.disabledReloadAnimationIndexPaths.contains($0) }
                beginUpdates()
                reloadRows(at: rowsWithAnimation, with: diffAnimation.reloadAnimation)
                reloadRows(at: rowsWithoutAnimation, with: .none)
                endUpdates()
            }

            CATransaction.commit()
    }
}
