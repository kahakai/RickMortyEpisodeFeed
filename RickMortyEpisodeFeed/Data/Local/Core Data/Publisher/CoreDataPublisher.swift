//
//  CoreDataPublisher.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import Foundation
import Combine
import CoreData

struct CoreDataPublisher<T>: Publisher where T: NSManagedObject {
    typealias Output = [T]
    typealias Failure = NSError

    private let context: NSManagedObjectContext
    private let request: NSFetchRequest<T>

    init(context: NSManagedObjectContext, request: NSFetchRequest<T>) {
        self.context = context
        self.request = request
    }

    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, request: request)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreDataPublisher {
    class Subscription<S> where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private var context: NSManagedObjectContext
        private var request: NSFetchRequest<T>
        
        init(
            subscriber: S,
            context: NSManagedObjectContext,
            request: NSFetchRequest<T>
        ) {
            self.subscriber = subscriber
            self.context = context
            self.request = request
        }
    }
}

extension CoreDataPublisher.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber = subscriber, demand > 0 else { return }
        do {
            demand -= 1
            let items = try context.fetch(request)
            demand += subscriber.receive(items)
        } catch {
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension CoreDataPublisher.Subscription: Cancellable {
    func cancel() {
        subscriber = nil
    }
}
