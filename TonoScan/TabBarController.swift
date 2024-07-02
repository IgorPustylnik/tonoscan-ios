import UIKit

class TabBarController: UITabBarController {
    private let cameraNav = UINavigationController(rootViewController: CameraController(cameraService: CameraService()))
    private let profileNav = UINavigationController(rootViewController: ProfileController())

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        self.setupTabs()
    }
    
    private func setupTabs() {
        cameraNav.tabBarItem.title = "Камера"
        cameraNav.tabBarItem.image = UIImage(systemName: "camera.fill")
        profileNav.tabBarItem.title = "Профиль"
        profileNav.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        
        self.navigationController?.navigationBar.isHidden = true
        profileNav.navigationBar.isHidden = true
        cameraNav.navigationBar.isHidden = true
        
        self.setViewControllers([cameraNav, profileNav], animated: true)
    }
}
