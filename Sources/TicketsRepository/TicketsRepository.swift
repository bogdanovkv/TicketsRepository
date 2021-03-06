//
//  TicketsRepository.swift
//  SBTSwiftProject
//
//  Created by Константин Богданов on 03.11.2020.
//  Copyright © 2020 Константин Богданов. All rights reserved.
//

import Foundation
import TicketsRepositoryAbstraction
import NetworkAbstraction

public final class TicketsRepository: TicketsRepositoryProtocol {
	private let token = "fe17c550289588390f32bb8a4caf562f"

	private enum Endpoint: String {
		case popularDirection = "http://api.travelpayouts.com/v1/city-directions"
		case search = "http://api.travelpayouts.com/v1/prices/cheap"
	}

	private struct Resonse: Decodable {
		let success: Bool
		let data: [String: [String: TicketDataModel]]

		enum CodingKeys: String, CodingKey {
			case success
			case data
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			success = try container.decode(Bool.self, forKey: .success)
			data = try container.decode([String: [String: TicketDataModel]].self, forKey: .data)
		}
	}

	private let networkService: NetworkServiceProtocol

	/// Инициализатор
	/// - Parameter networkService: сервис работы с сетью
	public init(networkService: NetworkServiceProtocol) {
		self.networkService = networkService
	}

	public func loadTickets(fromCityCodeIATA: String,
					 fromDate: Date?,
					 toCityCodeIATA: String,
					 returnDate: Date?,
					 _ completion: @escaping (Result<[TicketModel], Error>) -> Void) {
		guard let url = URL(string: Endpoint.search.rawValue) else {
			return completion(.failure(TicketsRepositoryError.urlError))
		}
		var parameters: [NetworkRequest.Parameter] = []
		parameters.append(.init(key: "token", value: token))
		parameters.append(.init(key: "origin", value: fromCityCodeIATA))
		parameters.append(.init(key: "destination", value: toCityCodeIATA))
		if let returnDate = returnDate {
			parameters.append(.init(key: "return_date", value: string(from: returnDate)))
		}
		if let fromDate = fromDate {
				parameters.append(.init(key: "depart_date", value: string(from: fromDate)))
		}

		let request = NetworkRequest(url: url,
									 method: .GET,
									 parameters: parameters)

		let onComplete: (Result<NetworkResponse<Resonse>, Error>) -> Void = { result in
			do {
				let result = try result.get()
				var models: [TicketDataModel] = []
				guard let response = result.data else {
					return completion(.success([]))
				}
				let dictionary = response.data
				dictionary.forEach { _, dict in
					dict.forEach { _, model in
						models.append(model)
					}
				}
				completion(.success(models.map({ $0.ticketValue() })))
			} catch {
				completion(.failure(error))
			}
		}
		networkService.perfom(request: request, onComplete)
	}

	private func string(from date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM"
		return formatter.string(from: date)
	}
}
