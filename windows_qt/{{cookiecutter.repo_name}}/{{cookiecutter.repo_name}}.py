#!/usr/bin/env python3
import sys

from PySide6 import QtCore, QtWidgets

from {{cookiecutter.repo_name}}_ui import Ui_MainWindow

__version__ = "{{cookiecutter.version}}"


class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

    @QtCore.Slot()
    def on_action_exit_triggered(self):
        self.close()

    @QtCore.Slot()
    def on_action_about_triggered(self):
        about_text = "<br>".join([f"<b>{{cookiecutter.repo_name}}</b> V{__version__}", "", "This is a PySide6 application."])
        QtWidgets.QMessageBox.about(self, "About", about_text)

    @QtCore.Slot()
    def on_push_button_clicked(self):
        self.ui.status_bar.showMessage("Popping up an informative message box...")
        QtWidgets.QMessageBox.information(self, "Button clicked", "You clicked the button...")
        self.ui.status_bar.clearMessage()


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())
