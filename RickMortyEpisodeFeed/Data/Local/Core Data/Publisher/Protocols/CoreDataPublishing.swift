//
//  CoreDataPublishing.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import CoreData

protocol CoreDataPublishing {
    func publisher<T: NSManagedObject>(
        context: NSManagedObjectContext,
        fetch request: NSFetchRequest<T>
    ) -> CoreDataPublisher<T>
}
