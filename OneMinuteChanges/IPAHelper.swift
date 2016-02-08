//
//  InAppPurchaseViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 2/8/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import StoreKit

class IAPHelper: NSObject
{
    let productIdentifiers: Set<ProductIdentifier>?
    var purchasedProductIdentifiers = Set<ProductIdentifier>()
    
    var productsRequest: SKProductsRequest?
    var completionHandler: RequestProductsCompletionHandler?
    
    /// MARK: - User facing API
    /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
    init(productIdentifiers: Set<ProductIdentifier>)
    {
        self.productIdentifiers = productIdentifiers
        super.init()
    }
    
    
    /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
    func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler)
    {
        self.completionHandler = handler
        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers!)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    /// Initiates purchase of a product.
    func purchaseProduct(product: SKProduct)
    {
        
    }
    
    /// Given the product identifier, returns true if that product has been purchased.
    func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool
    {
        return false
    }
    
    /// If the state of whether purchases have been made is lost  (e.g. the
    /// user deletes and reinstalls the app) this will recover the purchases.
    func restoreCompletedTransactions()
    {
        
    }

}

extension IAPHelper: SKProductsRequestDelegate
{
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        NSLog("Loaded list of products...")
        let products = response.products as! [SKProduct]
        
    }
}