//
//  ViewController.swift
//  Weather forecast
//
//  Created by RajeshKumar on 24/03/21.
//

import UIKit
import CoreData

class WeatherViewController: UIViewController,UITextFieldDelegate {
    
    let reachability = try! Reachability()
    var flag : Bool = true
    var favoriteDestinationsArr = [String]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoriteDestinationsHeight: NSLayoutConstraint!
    @IBOutlet weak var favoriteDestinationsTopView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentIcon: UIImageView!
    @IBOutlet weak var currentSummaryLabel: UILabel!
    @IBOutlet weak var forecastSummary: UITextView!
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var tempFormat: UILabel!
    @IBOutlet weak var favoriteDestinations: UIButton!
    
  private let viewModel = WeatherViewModel()
  
  override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setUpStyles()
        loadViewModel()
        favoriteDestinationsArr = CoreDataManager.shared.fetchFavoriteDestinationsData()
        reachability.whenReachable = { _ in
            DispatchQueue.main.async {
                self.view.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            }
        }
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                self.view.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                let alert = UIAlertController(title: "Internet Error", message: "Please Check your Internet Conectivity", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        do{
            try reachability.startNotifier()
        }catch{
            print("reachability Notifier not started")
        }
        
        tableView.register(UINib(nibName: "FavoriteDestinationsCell", bundle: nil), forCellReuseIdentifier: "FavoriteDestinationsCell")
  }
    
    func textFieldShouldReturn(_ searchLocationTextField: UITextField) -> Bool {
        if let newLocation = self.searchLocationTextField.text{
            self.getDataBasedOnReachability(location: newLocation)
//            self.viewModel.changeLocation(to: newLocation)
            self.searchLocationTextField.text = nil
        }
        self.view.endEditing(true)
            return true
        }
    
    func createData(cityName : String){
       let data = FavoriteDestinationsData(context: PersistentStorage.shared.context)
        data.cityname = cityName.capitalized
        PersistentStorage.shared.saveContext()
    }
    
    func setupDelegate(){
        searchLocationTextField.delegate = self
        searchLocationTextField.returnKeyType = UIReturnKeyType.done
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func setUpStyles(){
        setGradient(viewName: containerView, colors: [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)])
        searchLocationTextField.layer.masksToBounds = true
        searchLocationTextField.layer.borderColor = UIColor.white.cgColor
        searchLocationTextField.layer.borderWidth = 2.0
        searchLocationTextField.layer.cornerRadius = 17.0
        searchLocationTextField.addPaddingToTextField()
        view.bringSubviewToFront(dateLabel)
        view.bringSubviewToFront(currentIcon)
        view.bringSubviewToFront(currentSummaryLabel)
        view.bringSubviewToFront(forecastSummary)
        view.sendSubviewToBack(imageView)
        favoriteDestinations.layer.borderWidth = 2
        favoriteDestinations.layer.borderColor = UIColor.white.cgColor
        favoriteDestinationsHeight.constant = 0
        self.favoriteDestinationsTopView.isHidden = true
    }

  func loadViewModel(){
   
    viewModel.locationName.bind { [weak self] (locationName) in
      self?.cityLabel.text = locationName
    }
    
    viewModel.date.bind { [weak self] (date) in
      self?.dateLabel.text = date
    }
    
    viewModel.icon.bind { [weak self] (image) in
      self?.currentIcon.image = image
        UIView.transition(with: (self?.currentIcon!)!,
                                  duration: 1.0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self?.currentIcon.image = image
                }, completion: nil)
    }
    
    viewModel.summary.bind { [self] (summary) in
        self.currentSummaryLabel.text = summary
    }
    
    viewModel.tempFormat.bind{ [weak self] (tempFormat) in
        self?.tempFormat.text = tempFormat
      }
    
    viewModel.forecastSummary.bind { [weak self] (fSummary) in
      self?.forecastSummary.text = fSummary
    }
  }
    
    @IBAction func promptForLocation(_ sender: Any) {
        self.searchLocationTextField.endEditing(true)
        guard let newLocation = self.searchLocationTextField.text else {
            return
        }
        self.getDataBasedOnReachability(location: newLocation)
//        self.viewModel.changeLocation(to: newLocation)
        self.searchLocationTextField.text = nil
        
//        let alert = UIAlertController(
//          title: "Choose location",
//          message: nil,
//          preferredStyle: .alert)
//        alert.addTextField()
//        //2
//        let submitAction = UIAlertAction(
//          title: "Submit",
//          style: .default) { [unowned alert, weak self] _ in
//            guard let newLocation = alert.textFields?.first?.text else { return }
//            self?.viewModel.changeLocation(to: newLocation)
//        }
//        alert.addAction(submitAction)
        //3
//        present(alert, animated: true)
    }
    
    @IBAction func favoriteDestinationsAction(_ sender: UIButton) {
        showAndHideFavoriteDestinations()
    }
    
    @IBAction func addFavoriteDestination(_ sender: UIButton) {
        let alert = UIAlertController(
          title: "Add Favorite Destination",
          message: nil,
          preferredStyle: .alert)
        alert.addTextField{
            (newFavoriteDestination) in
            newFavoriteDestination.placeholder = "Enter Favorite Destination"
        }
        //2
        let submitAction = UIAlertAction(
          title: "Add",
          style: .default) { [unowned alert, weak self] _ in
            guard let newFavoriteDestination = alert.textFields?.first?.text else { return }
            print(newFavoriteDestination)
            self!.addDataToTabelView(cityName: newFavoriteDestination)
            CoreDataManager.shared.createFavoriteDestinationsData(cityName: newFavoriteDestination)
        }
        alert.addAction(submitAction)
        //3
        present(alert, animated: true)
    }
    
    func addDataToTabelView(cityName : String){
        let index = 0
        favoriteDestinationsArr.insert(cityName.capitalized, at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: .right)
    }
    
    func showAndHideFavoriteDestinations(){
        if flag{
            UIView.animate(withDuration: 1) {
                self.favoriteDestinationsHeight.constant = 300
                self.favoriteDestinationsTopView.isHidden = false
                self.favoriteDestinations.setImage(UIImage(systemName: "chevron.down" ), for: .normal)
                self.view.layoutIfNeeded()
               }
            flag = false
            
        }else{
            UIView.animate(withDuration: 1) {
                self.favoriteDestinationsHeight.constant = 0
                self.favoriteDestinationsTopView.isHidden = true
                self.favoriteDestinations.setImage(UIImage(systemName: "chevron.up" ), for: .normal)
                self.view.layoutIfNeeded()
               }
            flag = true
            
        }
    }
    
    func setGradient(viewName : UIView , colors : [CGColor] ) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colors
        gradient.locations = [0.0 , 1.0]
        gradient.frame = viewName.layer.frame
        viewName.layer.insertSublayer(gradient, at: 0)
    }
    
    func getDataBasedOnReachability(location : String){
        if (reachability.isReachable){
            print("conected")
            self.viewModel.changeLocation(to: location)
        }else{
            print("not conected")
            let alert = UIAlertController(title: "Internet Error", message: "Loading Data  from fast History", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.viewModel.getLocationData(to: location)
        }
    }
    
}
extension WeatherViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteDestinationsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteDestinationsCell", for: indexPath) as! FavoriteDestinationsCell
        cell.cityName.text = favoriteDestinationsArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        CoreDataManager.shared.deleteFavoriteDestinationsData(city:favoriteDestinationsArr[indexPath.row])
        favoriteDestinationsArr.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showAndHideFavoriteDestinations()
        getDataBasedOnReachability(location: favoriteDestinationsArr[indexPath.row])
    }
}

extension UITextField {
    func addPaddingToTextField() {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 10, y: 0, width: 8, height: 20))
        self.leftView = paddingView;
        self.leftViewMode = .always;
        self.rightView = paddingView;
        self.rightViewMode = .always;
    }
}


