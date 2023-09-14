//
//  CoreDataPublishingExtension.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import CoreData

extension CoreDataPublishing {
    func publisher<T: NSManagedObject>(
        context: NSManagedObjectContext,
        fetch request: NSFetchRequest<T>
    ) -> CoreDataPublisher<T> {
        return CoreDataPublisher(context: context, request: request)
    }
}
