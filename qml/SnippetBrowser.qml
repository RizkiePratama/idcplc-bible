import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

// SQLite driver
import QtQuick.LocalStorage 2.0

// Snippet browser
// Container untuk button add snippet dan listview
// Minimal width 200, maximal width 400, default width 250 (@geger009)
Rectangle {
    id: snippetBrowser
    property alias browser : browser
    property alias txtSearch : txtSearch

    color: "#323844"
    width: 250
    height: parent.height
    Layout.minimumWidth: 100
    Layout.maximumWidth: 400

    // Search bar
    Rectangle {
        color: "transparent"
        width: parent.width
        height: 30

        // Magnifier button
        Button {
            iconSource: "qrc:/res/magnifying_glass.png"
            width: 30
            height: parent.height
            anchors.leftMargin: 10
            anchors.left: parent.left
            style: ButtonStyle {
                background: Rectangle {
                    color: "transparent"
                }
            }
        }

        // Search text field
        TextField {
            id: txtSearch
            placeholderText: qsTr("Search...")
            height: parent.height
            anchors.leftMargin: 40
            anchors.left: parent.left
            anchors.rightMargin: 40
            anchors.right: parent.right
            style: TextFieldStyle {
                placeholderTextColor: "darkGray"
                textColor: "white"
                background: Rectangle {
                    color: "transparent"
                }
            }

            Keys.onReturnPressed: {
                mainWindow.reload();
            }
        }

        // Plus button
        Button {
            id: btnAddSnippet
            objectName: "btnAddSnippet"
            iconSource: "qrc:/res/plus.png"
            width: 30
            height: parent.height
            anchors.rightMargin: 10
            anchors.right: parent.right
            style: ButtonStyle {
                background: Rectangle {
                    color: "transparent"
                }
            }
            onClicked:
            {
                addSnippetView.visible = true
            }
        }
    }

    // Separator
    Rectangle {
        color: "#3D4451"
        x: 0
        y: 30
        height: 1
        anchors.left: parent.left
        anchors.right: parent.right
    }

    // View untuk menampilkan daftar snippets (panel kiri).
    ListView {
        id: browser
        x: 0
        width: 250
        anchors.top: parent.top
        anchors.topMargin: 31
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        flickableDirection: Flickable.HorizontalFlick
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.left: parent.left
        anchors.right: parent.right
        highlight: Rectangle {
            color: "#2B303B"
        }
        focus: true

        function displayCodeByIndex(index) {
            db.transaction (function(tx) {
                var rs = tx.executeSql ('select title, description, snippet from TSnippets where xid=?', [index]);
                codeViewer.labelTitle.text = rs.rows.item(0).title;
                codeViewer.labelDescription.text = rs.rows.item(0).description;
                codeViewer.sourceView.text = rs.rows.item(0).snippet;
            })
        }

        model: mainWindow.mdl

        delegate: Component {
            Item {
                width: parent.width
                height: 60

                // Title label
                Label {
                    y: 10
                    height: 15
                    text: model.modelData.title
                    verticalAlignment: Text.AlignVCenter
                    color: "lightgray"
                    anchors.leftMargin: 10
                    anchors.left: parent.left
                    anchors.rightMargin: 10
                    anchors.right: parent.right
                }

                // Platform label
                Label {
                    y: 35
                    height: 15
                    text: "Linux"
                    verticalAlignment: Text.AlignVCenter
                    color: "#929A97"
                    anchors.leftMargin: 10
                    anchors.left: parent.left
                    anchors.rightMargin: 10
                    anchors.right: parent.right
                }

                // Datetime label
                Label {
                    y: 35
                    height: 15
                    text: "10:45"
                    verticalAlignment: Text.AlignVCenter
                    color: "#929A97"
                    anchors.rightMargin: 10
                    anchors.right: parent.right
                }

                // Separator
                Rectangle {
                    color: "#3D4451"
                    y: 59
                    height: 1
                    anchors.left: parent.left
                    anchors.right: parent.right
                }


                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent

                    // On select item with mouse click
                    onClicked: {
                        browser.focus = true
                        browser.currentIndex = index

                        parent.parent.parent.displayCodeByIndex(model.modelData.xid);
                    }
                }
            }
        } // delegate

        // Navigate snippet using key up.
        Keys.onUpPressed: {
            if (count > 0 && currentIndex > 0)
            {
                currentIndex--;
                displayCodeByIndex(model[currentIndex].xid);
            }
        }

        // Navigate snippet using key down.
        Keys.onDownPressed: {
            if (currentIndex < (count-1))
            {
                currentIndex++;
                displayCodeByIndex(model[currentIndex].xid);
            }
        }

        Keys.onReturnPressed: {
            var index = model[currentIndex].xid;
            db.transaction (function(tx) {
                var rs = tx.executeSql ("SELECT contributor, title, category, languages, description, snippet FROM TSnippets WHERE xid=?", [index]);
                addSnippetView.idValue = index;
                addSnippetView.contributorText = rs.rows.item(0).contributor;
                addSnippetView.titleText = rs.rows.item(0).title;
                addSnippetView.categoryText = rs.rows.item(0).category;
                addSnippetView.descriptionText = rs.rows.item(0).description;
                addSnippetView.snippetText = rs.rows.item(0).snippet;
                addSnippetView.visible = true;
            });
        }
    } // ListView
} // Snippet browser
