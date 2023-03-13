//
//  PersistentContainer.swift
//  DB challenge
//
//  Created by Zofia Drabek on 12.03.23.
//

import CoreData

class PersistentContainer: NSPersistentContainer {
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
    
    func fetchAllFavorites() -> [Int] {
        let fetchRequest = Favorite.fetchRequest()
        
        do {
            let favorites = try viewContext.fetch(fetchRequest)
            return favorites.map(\.id).map(Int.init)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return [0]
    }
    
    func addFavorite(_ id: Int) {
        let favorite = Favorite(withEntityDerivedFromContext: viewContext)
        favorite.id = Int64(id)
                
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func removeFavorite(_ id: Int) {
        let fetchRequest = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let favorites = try viewContext.fetch(fetchRequest)
            for favorite in favorites {
                viewContext.delete(favorite)
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    func removeAllFavorites() {
        let fetchRequest = Favorite.fetchRequest()
        do {
            let favorites = try viewContext.fetch(fetchRequest)
            for favorite in favorites {
                viewContext.delete(favorite)
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
}

public extension NSManagedObject {
    convenience init(withEntityDerivedFromContext context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
