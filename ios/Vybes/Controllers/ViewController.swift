import UIKit

/// Main View of the app
class ViewController: UIViewController {
  /// Textfield for entry input.
  @IBOutlet weak var entryTextView: UITextView!
  /// The original frame of the entryTextView. Needed for resetting the size when done editing.
  var entryTextViewFrame: CGRect!
  /// TableView for displaying entries.
  @IBOutlet weak var entriesTableView: UITableView!
  @IBOutlet weak var entryTextFieldHeightConstraint: NSLayoutConstraint!
  /// Keep track of all JournalEntry's that user has created.
  var entries = [Entry]() {
    didSet {
      DispatchQueue.main.async { 
        self.entriesTableView.reloadData()
      }
    }
  }
  /// Holds the most recent entry that was edited by the user.
  private var indexOfEditedEntry: Int?

  override func viewDidLoad() {
    super.viewDidLoad()
    entriesTableView.dataSource = self
    entriesTableView.delegate = self
    entriesTableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
    entriesTableView.estimatedRowHeight = 80

    entryTextView.layer.cornerRadius = entryTextView.frame.height / 4
    entryTextViewFrame = entryTextView.frame
    // Observe behavior of keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: .UIKeyboardWillShow, object: view.window)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: .UIKeyboardWillHide, object: view.window)
    view.addTapToDismissKeyboardGesture()
    getEntries()
  }

  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
  }

  @IBAction func submitButtonPressed(_ sender: Any) {
    guard let entryText = entryTextView.text else { return }
    guard let user = NetworkManager.shared.user else { return }

    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: date)
    let newEntry = Entry(date: today, body: entryText)
    if let index = indexOfEditedEntry {
      entries[index] = newEntry
      indexOfEditedEntry = nil
    } else {
      entries.append(newEntry)
      user.post(entry: newEntry)
    }
    entriesTableView.reloadData()
    scrollToBottom()
    entryTextView.text = ""
    view.endEditing(true)
  }

  func getEntries() {
    guard let user = NetworkManager.shared.user else {
      tryAgainAfterLogin()
      return
    }
    user.getEntries() { [unowned self] entries in
      self.entries = entries
    }
  }

  private func tryAgainAfterLogin() {
    if let email = UserDefaults.standard.string(forKey: "email"),
      let password = UserDefaults.standard.string(forKey: "password") {
      NetworkManager.shared.login(email: email, password: password) { [unowned self] _ in
        self.getEntries()
      }
    }
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell") as? EntryTableViewCell else {
      return UITableViewCell()
    }
    let entry = entries[indexPath.row]
    cell.entry = entry
    return cell
  }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("🤥")
  }


  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let editCellAction = UITableViewRowAction(style: .normal, title: "edit") { [unowned self] (action, index) in
      let entry = self.entries[indexPath.row]
      self.entryTextView.becomeFirstResponder()
      self.entryTextView.text = entry.body
      self.indexOfEditedEntry = indexPath.row
    }

    let deleteCellAction = UITableViewRowAction(style: .destructive, title: "delete") { [unowned self] (action, index) in
      guard let user = NetworkManager.shared.user else { return }
      user.delete(entry: self.entries[indexPath.row])
      self.entries.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    return [deleteCellAction, editCellAction]
  }
}

// MARK: Keyboard notification
private extension ViewController {
  @objc func keyboardWillShow(notification: NSNotification) {
    let userInfo = notification.userInfo!

    let keyboardSize: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
    if view.frame.origin.y == 0 {
      UIView.animate(withDuration: 0.5, animations: { () -> Void in
        self.view.frame.origin.y -= keyboardSize.height - self.entryTextView.frame.size.height
        self.entriesTableView.contentInset = UIEdgeInsetsMake(70 + keyboardSize.height, 0, 70 + keyboardSize.height, 0)
        let frame = self.entryTextView.frame
        self.entryTextView.frame = CGRect(x: frame.origin.x,
                                          y: frame.origin.y - keyboardSize.height,
                                          width: frame.width,
                                          height: frame.height + keyboardSize.height)
      })
    }
  }

  @objc func keyboardWillHide(notification: NSNotification) {
    UIView.animate(withDuration: 0.5, animations: { () -> Void in
      self.view.frame.origin.y = 0
      self.entriesTableView.contentInset = UIEdgeInsetsMake(70, 0, 70, 0)
      self.entryTextView.frame = self.entryTextViewFrame
    })
  }
}

// MARK: Helper methods
private extension ViewController {
  /// Scroll the tableview to the bottom of the view.
  func scrollToBottom() {
    DispatchQueue.main.async {
      let indexPath = IndexPath(row: self.entries.count - 1, section: 0)
      self.entriesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
}

extension ViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
}