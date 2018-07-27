//
//  UITableView+Diff.swift
//  HeckelDiff
//
//  Created by Matias Cudich on 11/23/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
    /// Applies a batch update to the receiver, efficiently reporting changes between old and new.
    ///
    /// - parameter old:       The previous state of the table view.
    /// - parameter new:       The current state of the table view.
    /// - parameter section:   The section where these changes took place.
    /// - parameter insertAnimation: The animation type for insertion.
    /// - parameter deleteAnimation: The animation type for deletion.
    /// - parameter reloadAnimation: The animation type for reload.
    func applyDiff<T: Collection>(_ old: T, _ new: T, inSection section: Int, withInsertAnimation insertAnimation: UITableViewRowAnimation, withDeleteAnimation deleteAnimation: UITableViewRowAnimation, withReloadAnimation reloadAnimation: UITableViewRowAnimation, completion: @escaping () -> Void) where T.Iterator.Element: Hashable, T.IndexDistance == Int, T.Index == Int {
        let update = ListUpdate(diff(old, new), section)

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        beginUpdates()
        deleteRows(at: update.deletions, with: deleteAnimation)
        insertRows(at: update.insertions, with: insertAnimation)
        for move in update.moves {
            moveRow(at: move.from, to: move.to)
        }
        endUpdates()
        
        // reloadItems is done separately as the update indexes returne by diff() are in respect to the
        // "after" state, but the collectionView.reloadItems() call wants the "before" indexPaths.
        if update.updates.count > 0 {
            beginUpdates()
            reloadRows(at: update.updates, with: reloadAnimation)
            endUpdates()
        }
        
        CATransaction.commit()
    }
}
