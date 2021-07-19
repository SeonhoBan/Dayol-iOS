//
//  PersistentManager.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/06/13.
//

import Foundation
import CoreData

class PersistentManager {
    enum EntityType {
        case diary
        case paper
        case paperScheduler
        case decorationItem
        case decorationTextFieldItem
        case decorationStickerItem
        case decorationImageItemMO

        var name: String {
            switch self {
            case .diary: return "Diary"
            case .paper: return "Paper"
            case .paperScheduler: return "PaperScheduler"
            case .decorationItem: return "DecorationItem"
            case .decorationTextFieldItem: return "DecorationTextFieldItem"
            case .decorationStickerItem: return "DecorationStickerItem"
            case .decorationImageItemMO: return "DecorationImageItem"
            }
        }
    }
    static let shared: PersistentManager = PersistentManager()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Dayol")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                DYLog.e(.coreData, in: PersistentManager.self, value: "Unresolved Error \(error) | \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                let error = error as NSError
                DYLog.e(.coreData, in: Self.self, value: "Unresolved Error \(error) | \(error.userInfo)")
            }
        }
    }

    private func entity(_ type: EntityType) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: type.name, in: persistentContainer.viewContext)
    }

    func managedObject<T: NSManagedObject>(_ type: EntityType, class: T.Type) -> T? {
        if let entity = entity(.diary) {
            return T(entity: entity, insertInto: context)
        }
        return nil
    }

    func insertObject(_ type: EntityType) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: type.name, into: persistentContainer.viewContext)
    }

    func deleteManagedObject(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }
}

// MARK: - Fetch

extension PersistentManager {

    func fetch<T: NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<T>) -> [T]? {
        do {
            let result = try context.fetch(fetchRequest)
            return result
        }
        catch {
            let error = error as NSError
            DYLog.e(.coreData, in: Self.self, value: "Fetch Error \(error) | \(error.userInfo)")
            return nil
        }
    }
}
