//
//  HomeViewController.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Outlets
    
    @IBOutlet private weak var priceTypeBtn: UIButton!
    @IBOutlet private weak var searchBtn: UIButton!
    @IBOutlet private weak var coinsInfoListView: CoinsInfoListView!
    @IBOutlet private weak var blackTransparentView: UIView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var searchTextField: UITextField!

    // MARK: - Private Properties
    
    private let viewModelBag = DisposeBag()
    private let uiBag = DisposeBag()
    private let viewModel = HomeViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUIInitialState()
        setupViewModelBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateData.accept(())
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTextField.text = nil
        configureSearchMode(isEnabled: false)
        return true
    }
    
    // MARK: - Private API
    
    private func setupViewModelBindings() {
        viewModel
            .priceTypeBtnTitle
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: priceTypeBtn.rx.title())
            .disposed(by: viewModelBag)
        
        viewModel
            .coinsInfoListViewModel
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (coinsInfoListViewModel) in
                self?.coinsInfoListView.setupViewModel(coinsInfoListViewModel)
            })
            .disposed(by: viewModelBag)
        
        viewModel
            .isLoading
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in

            })
            .disposed(by: viewModelBag)
        
        viewModel
            .error
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in

            })
            .disposed(by: viewModelBag)
        
        viewModel
            .isLoading
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: viewModelBag)
        
        viewModel
            .isLoading
            .map({ !$0 })
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: blackTransparentView.rx.isHidden)
            .disposed(by: viewModelBag)
        
        priceTypeBtn
            .rx
            .tap
            .bind(to: viewModel.priceTypeBtnTap)
            .disposed(by: viewModelBag)
        
        searchTextField
            .rx
            .text
            .bind(to: viewModel.searchPhrase)
            .disposed(by: viewModelBag)
    }
    
    private func configureUIInitialState() {
        // Configuring price type button
        priceTypeBtn.titleLabel?.numberOfLines = 1
        priceTypeBtn.titleLabel?.lineBreakMode = .byWordWrapping
        priceTypeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Configuring search text field
        addDoneButtonOnKeyboardForSearchTextField()
        searchTextField.clearButtonMode = .always
        searchTextField.delegate = self
        searchBtn
            .rx
            .tap
            .bind { [weak self] _ in
                self?.configureSearchMode(isEnabled: true)
            }
            .disposed(by: uiBag)
        
    }
    
    private func configureSearchMode(isEnabled: Bool) {
        UIView.animate(
            withDuration: 0.3,
            delay: .zero,
            options: []) { [weak self] in
                // Animating
                self?.searchTextField.alpha = isEnabled ? 1 : 0
            }
            completion: { [weak self] _ in
                // Doing needed logic
                if (!isEnabled) {
                    self?.searchTextField.resignFirstResponder()
                    self?.view.endEditing(true)
                }
                else {
                    self?.searchTextField.becomeFirstResponder()
                }
            }
    }
    
    private func addDoneButtonOnKeyboardForSearchTextField() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        searchTextField.inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction() {
        configureSearchMode(isEnabled: false)
    }
}
