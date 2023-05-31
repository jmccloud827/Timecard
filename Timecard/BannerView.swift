import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

struct BannerView: View {
    var size: CGSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size
    }
    
    var body: some View {
        BannerUiKitView().frame(width: size.width, height: size.height)
    }
    
    struct BannerUiKitView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> ViewController {
            ViewController()
        }
        
        func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
        
        class ViewController: UIViewController, GADBannerViewDelegate {
            var bannerView: GADBannerView!
            
            override func viewDidLoad() {
                super.viewDidLoad()
                
                bannerView = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
#if DEBUG
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
#else
                bannerView.adUnitID = "ca-app-pub-7876954544180802/8040279450"
#endif
                bannerView.rootViewController = self
                bannerView.delegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        if status != .notDetermined && status != .restricted {
                            GADMobileAds.sharedInstance().start(completionHandler: nil)
                            self.bannerView.load(GADRequest())
                        }
                    }
                }
            }
            
            func addBannerViewToView(_ bannerView: GADBannerView) {
                bannerView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(bannerView)
                view.addConstraints(
                    [NSLayoutConstraint(item: bannerView,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: view.safeAreaLayoutGuide,
                                        attribute: .bottom,
                                        multiplier: 1,
                                        constant: 0),
                     NSLayoutConstraint(item: bannerView,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: view,
                                        attribute: .centerX,
                                        multiplier: 1,
                                        constant: 0)
                    ])
            }
            
            func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
                print("bannerViewDidReceiveAd")
                addBannerViewToView(bannerView)
                bannerView.alpha = 0
                UIView.animate(withDuration: 1) {
                    bannerView.alpha = 1
                }
            }
            
            func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
                print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
            }
            
            func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
                print("bannerViewDidRecordImpression")
            }
            
            func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
                print("bannerViewWillPresentScreen")
            }
            
            func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
                print("bannerViewWillDIsmissScreen")
            }
            
            func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
                print("bannerViewDidDismissScreen")
            }
            
        }
    }
}
