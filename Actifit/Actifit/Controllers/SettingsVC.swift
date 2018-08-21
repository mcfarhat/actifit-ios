//
//  SettingsVC.swift
//  Actifit
//
//  Created by Hitender kumar on 20/08/18.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var metricMeasurementSystemBtn : UIButton!
    @IBOutlet weak var USMeasurementSystemBtn : UIButton!
    @IBOutlet weak var donateTopCharityBtn : UIButton!
    @IBOutlet weak var metricDotView : UIView!
    @IBOutlet weak var usDotView : UIView!
    @IBOutlet weak var charityInfoLabel : UILabel!
    @IBOutlet weak var saveSettingsBtn : UIButton!
    @IBOutlet weak var showCharityBtn : UIButton!

    @IBOutlet weak var metricMeasurementSystemBtnDotViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var metricMeasurementSystemBtnDotViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var USMeasurementSystemBtnDotViewWidthConstraint  : NSLayoutConstraint!
    @IBOutlet weak var USMeasurementSystemBtnDotViewHeightConstraint  : NSLayoutConstraint!

    var isMetricSystemSelected = false
    var isDonateToCharitySelected = false
    
    var charities = [Charity]()
    
    //MARK: VIEW LIFE CYCLE
    
    lazy var settings = {
        return Settings.current()
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCharities()
        if let settings = self.settings {
            self.isMetricSystemSelected = settings.measurementSystem == MeasurementSystem.metric.rawValue
            self.isDonateToCharitySelected = settings.isDonatingCharity
            self.showCharityBtn.setTitle(settings.charityName, for: .normal)
        }
        self.applyFinihingTouchToUIElements()
    }
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func metricMeasurementSystemBtnAction(_ sender : UIButton) {
        self.isMetricSystemSelected = true
        self.selectMetricSystem(select: true)
        self.selectUSSystem(select: false)
    }
    
    @IBAction func usMeasurementSystemBtnAction(_ sender : UIButton) {
        self.isMetricSystemSelected = false
        self.selectUSSystem(select: true)
        self.selectMetricSystem(select: false)
    }
    
    @IBAction func donateTopCharityBtnAction(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.isDonateToCharitySelected = sender.isSelected
        self.donateTopCharityBtn.layer.borderColor = sender.isSelected ? UIColor.clear.cgColor :  UIColor.darkGray.cgColor
        self.donateTopCharityBtn.layer.borderWidth = sender.isSelected ? 0.0 : 2.0
        if sender.isSelected {
            self.donateTopCharityBtn.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.donateTopCharityBtn.tintColor = ColorTheme
        } else {
            self.donateTopCharityBtn.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func showCharitiesBtnAction(_ sender : UIButton) {
        if self.charities.count == 0 {
            self.showAlertWith(title: nil, message: "No Charity available")
            return
        }
        
        if let nib = Bundle.main.loadNibNamed("ActivityTypesView", owner: self, options: nil) {
            var objActivityTypesView : ActivityTypesView? = nib[0] as? ActivityTypesView
            objActivityTypesView?.activityTypesOrCharities = self.charities.map({$0.display_name})
            objActivityTypesView?.selectedActivities = (self.showCharityBtn.titleLabel?.text ?? "").components(separatedBy: CharacterSet.init(charactersIn: ","))
            objActivityTypesView?.isForCharity = true
            objActivityTypesView?.activitiesTableView.reloadData()
            self.view.addSubview(objActivityTypesView!)
            objActivityTypesView?.prepareForNewConstraints { (v) in
                v?.setLeadingSpaceFromSuperView(leadingSpace: 0)
                v?.setTrailingSpaceFromSuperView(trailingSpace: 0)
                v?.setTopSpaceFromSuperView(topSpace: 0)
                v?.setBottomSpaceFromSuperView(bottomSpace: 0)
            }
            objActivityTypesView?.SelectedActivityTypesCompletion = { selectedActivities in
                if selectedActivities.count > 0 {
                    self.showCharityBtn.setTitle(selectedActivities[0], for: .normal)
                }
                objActivityTypesView?.selectedActivities.removeAll()
                objActivityTypesView?.removeFromSuperview()
                objActivityTypesView = nil
            }
        }
    }
    
    @IBAction func saveSettingsBtnAction(_ sender : UIButton) {
        
        //metric system
        let charityDisplayName = self.showCharityBtn.titleLabel?.text ?? ""
        let charityName = self.charities.first(where: {$0.display_name == charityDisplayName})?.charity_name ?? ""

        if let settings = self.settings {
            settings.update(measurementSystem: self.isMetricSystemSelected ? .metric : .us, isDonatingCharity: self.isDonateToCharitySelected, charityName: self.isDonateToCharitySelected ? charityName : "", charityDisplayName: self.isDonateToCharitySelected ? charityDisplayName : "")
        } else {
            Settings.saveWith(info: [SettinsgKeys.measurementSystem : (self.isMetricSystemSelected ? MeasurementSystem.metric.rawValue : MeasurementSystem.us.rawValue), SettinsgKeys.isDonatingCharity : false, SettinsgKeys.charityName :  self.isDonateToCharitySelected ? charityName : "", SettinsgKeys.charityDisplayName : self.isDonateToCharitySelected ? charityDisplayName : ""])
        }
        
        self.showAlertWithOkCompletion(title: nil, message: "Settings has been saved") { (cl) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: HELPERS
    
    
    func applyFinihingTouchToUIElements() {
        
        self.backBtn.setImage(#imageLiteral(resourceName: "back_black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.backBtn.tintColor = UIColor.white
        
        self.metricDotView.backgroundColor = ColorTheme
        self.usDotView.backgroundColor = ColorTheme
        
        metricMeasurementSystemBtn.layer.cornerRadius = metricMeasurementSystemBtn.frame.size.width / 2
        USMeasurementSystemBtn.layer.cornerRadius = USMeasurementSystemBtn.frame.size.width / 2
        
        metricDotView.layer.cornerRadius = metricDotView.frame.size.width / 2
        usDotView.layer.cornerRadius = usDotView.frame.size.width / 2
        self.donateTopCharityBtn.layer.borderColor = UIColor.darkGray.cgColor
        self.donateTopCharityBtn.layer.borderWidth = 2.0
        self.donateTopCharityBtn.layer.cornerRadius = 2.0
        
        //update UI
        selectMetricSystem(select: self.isMetricSystemSelected)
        selectUSSystem(select: !self.isMetricSystemSelected)
        if self.isDonateToCharitySelected {
            self.donateTopCharityBtn.isSelected = true
            self.donateTopCharityBtn.layer.borderWidth = 0.0
            self.donateTopCharityBtn.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.donateTopCharityBtn.tintColor = ColorTheme
        }
    }
    
    func selectMetricSystem(select : Bool) {
        self.metricMeasurementSystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.metricMeasurementSystemBtn.layer.borderWidth = 2.0
        self.metricMeasurementSystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.metricMeasurementSystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func selectUSSystem(select : Bool) {
        self.USMeasurementSystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.USMeasurementSystemBtn.layer.borderWidth = 2.0
        self.USMeasurementSystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.USMeasurementSystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    //MARK: WEB SERVICES
    
    func loadCharities() {
        SwiftLoader.show(title: Messages.loading_charities, animated: true)
        APIMaster.getCharities(completion: { [weak self] (jsonString) in
            DispatchQueue.main.async(execute: {
                SwiftLoader.hide()
            })
            if let jsonString = jsonString as? String {
                let data = jsonString.utf8Data()
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonArray = (json as? [[String : Any]]){
                        self?.charities = jsonArray.map({Charity.init(info: $0)})
                    }
                } catch {
                    print("unable to fetch charities")
                }
            }
        }) { (error) in
            DispatchQueue.main.async(execute: {
                SwiftLoader.hide()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.showAlertWith(title: nil, message: error.localizedDescription)
            })
        }

    }
    
}