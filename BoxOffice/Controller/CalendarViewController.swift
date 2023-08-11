//
//  CalendarViewController.swift
//  BoxOffice
//
//  Created by Yetti, Maxhyunm on 2023/08/11.
//

import UIKit

final class CalendarViewController: UIViewController, UICalendarSelectionSingleDateDelegate {
    
    private let calendarView: UICalendarView = {
        var calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .systemBackground
        
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let calendarViewDateRange = DateInterval(start: Date(timeIntervalSince1970: 0), end: endDate)
        calendarView.availableDateRange = calendarViewDateRange

        return calendarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(calendarView)
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        let components = Calendar.current.dateComponents(in: .current, from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
        dateSelection.setSelected(components, animated: false)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        self.dismiss(animated: true)
    }
}
