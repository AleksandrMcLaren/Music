//
//  PresentViewController.swift
//  Music
//
//  Created by Aleksandr on 06.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

typealias CardViewPresentable = UIView & PresentCardPresentable

protocol PresentCardPresentable {
    var imView: ImageView { get set }
    var isPresenting: Bool { get set }
    var cornerRadius: CGFloat { get set }
    func convertRect(to view: UIView) -> CGRect
}

typealias DetailViewControllerPresentable = UIViewController & PresentDetailPresentable

protocol PresentDetailPresentable {
    var tableView: TableView! { get set }
    var tableViewDidScroll: ((_ scrollView: UIScrollView) -> Void)! { get set }
    var tableViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)! { get set }
}

protocol PresentViewControllerPresentable: class {
    var superVC: UIViewController! { get set }
    var cardView: CardViewPresentable! { get set }
    var cardOriginalFrame: CGRect { get set }
    var detailVC: DetailViewControllerPresentable! { get set }
    var isFullscreen: Bool { get set }
    var completionPresent: (() -> Swift.Void)? { get set }
}

class PresentViewController: UIViewController, PresentViewControllerPresentable {

    var superVC: UIViewController!
    var cardView: CardViewPresentable!
    var cardOriginalFrame = CGRect.zero
    var isFullscreen = true
    var detailVC: DetailViewControllerPresentable!
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    var completionPresent: (() -> Void)?
    fileprivate var presented = false
    fileprivate var originalFrame = CGRect.zero

    //MARK: - Lifecycle

    deinit {
        print("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(detailVC)
        view.addSubview(detailVC.view)

        detailVC.tableView.tableHeaderView = cardView.imView

        configureTableView()

        if isFullscreen == false {
            blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        }

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard presented == false else {
            return
        }

        presented = true

        view.insertSubview(blurView, belowSubview: detailVC.view)
        blurView.frame = view.bounds
        present()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        originalFrame = detailVC.view.frame
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    //MARK: - Layout & Animations for the content ( rect = Scrollview + card + detail )

    func layout(_ rect: CGRect, isPresenting: Bool, isAnimating: Bool = true, transform: CGAffineTransform = CGAffineTransform.identity){

        guard isPresenting else {
            detailVC.view.frame = rect.applying(transform)
            cardView.imView.frame = detailVC.view.bounds
            return
        }

        if isFullscreen {
            detailVC.view.frame = view.bounds
            detailVC.view.frame.origin.y = 0
        } else {
            detailVC.view.frame.size = CGSize(width: UIScreen.main.bounds.width / 100 * 85, height: 100 * UIScreen.main.bounds.height / 100 - 20)
            detailVC.view.center = blurView.center
            detailVC.view.frame.origin.y = 40
        }

        detailVC.view.frame = detailVC.view.frame.applying(transform)

        cardView.imView.frame.origin = detailVC.view.bounds.origin
        cardView.imView.frame.size = CGSize(width: detailVC.view.bounds.width,
                                            height: detailVC.view.bounds.width / 1.4)
    }

    //MARK: - Actions

    func present() {
        superVC.navigationController?.setNavigationBarHidden(true, animated: true)
        superVC.statusBarHidden = true

        let animator = PresentAnimator()
        animator.card = cardView
        animator.presenting = true
        animator.animateTransition(from: superVC, to: self)
        animator.endAnimation = { [unowned self] in
            // после анимаций бывает неверный фрейм, поставим нужный
            let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - (self.tabBarController?.tabBar.frame.height ?? 0))
            self.detailVC.tableView.frame = frame

            self.completionPresent?()
        }
    }

    func dismiss() {
        superVC.navigationController?.setNavigationBarHidden(false, animated: true)
        superVC.statusBarHidden = false

        let animator = PresentAnimator()
        animator.card = cardView
        animator.presenting = false
        animator.animateTransition(from: self, to: superVC)
    }

    @objc func dismissVC() {
        detailVC.tableView.contentOffset.y = 0
        dismiss()
    }

    // MARK: Configure

    func configureTableView() {
        let tableView = detailVC.tableView
        tableView?.layer.cornerRadius = isFullscreen ? 0 : 20
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false

        detailVC.tableViewDidScroll = { [unowned self] (scrollView) in
            self.scrollViewDidScroll(scrollView)
        }

        detailVC.tableViewWillEndDragging = { [unowned self] (scrollView, velocity, targetContentOffset) in
            self.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PresentViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if scrollView.contentOffset.y < -60  {
            detailVC.view.frame.origin = CGPoint(x: detailVC.tableView.frame.origin.x, y: -scrollView.contentOffset.y)
            detailVC.tableView.contentOffset = CGPoint(x: 0, y: 0)
            dismiss()
        }
    }
}
