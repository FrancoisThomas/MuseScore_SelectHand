import QtQuick 2.1
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import MuseScore 1.0

MuseScore {
	version: "0.2"
	description: qsTr("This plugin allows to mute one of the hand of a (single) piano score.")
	menuPath: "Plugins.Select Staff"
	property var rightHandStaffIdx : 0
	property var leftHandStaffIdx : 1
	property var processStaff : function(staffIdx, f) {
		var ret, i;
		var cursor = curScore.newCursor();
		cursor.rewind(0);

		curScore.startCmd();
		for (var voice = 0; voice < 4; voice++) {
			cursor.rewind(0); // beginning of score
			cursor.voice    = voice;
			cursor.staffIdx = staffIdx;

			while (cursor.segment) {
				if (cursor.element && cursor.element.type == Element.CHORD) {

					var graceChords = cursor.element.graceNotes;
					for (var i = 0; i < graceChords.length; i++) {
						// iterate through all grace chords
						var notes = graceChords[i].notes;

						for (var j = 0; j < notes.length; j++) {
							ret = f(notes[j], ret);
						}
					}

					var notes = cursor.element.notes;
					for (var j = 0; j < notes.length; j++) {
						ret = f(notes[j], ret);
					}
				} // end if CHORD
				cursor.next();
			} // end while segment
		} // end for voice
		curScore.endCmd();

		return ret;
	}
	property var playStaff : function(staffIdx, played) {
		console.log("Play staff " + staffIdx + ", " + played);
		function setPlayed(n, r) { n.play = played; };
		processStaff(staffIdx, setPlayed);
	}
	onRun: {
		function anyNotePlayed(staffIdx) {
			console.log("Any note played staff " + staffIdx);
			function isPlayed(n, acc) { return acc || n.play };
			return processStaff(staffIdx, isPlayed);
		}

		if (typeof curScore === 'undefined') {
			Qt.quit();
		}
		else {
			rightHandBox.checked = anyNotePlayed(rightHandStaffIdx);
			leftHandBox.checked = anyNotePlayed(leftHandStaffIdx);
			window.visible = true;
		}
	}

	Window {
		id : window
		width : 250
		height : 100
		visible : false
		title : qsTr("Select Staff Plugin")

		onClosing : {
			playStaff(rightHandStaffIdx, true);
			playStaff(leftHandStaffIdx, true);
			Qt.quit();
		}

		Label {
			id : textLabel
			wrapMode : Text.WordWrap
			text : qsTr("Select which staff to play:")
			font.pointSize : 12
			anchors.left : window.left
			anchors.top : window.top
			anchors.leftMargin : 10
			anchors.topMargin : 10
		}

		Label {
			id : rightHandLabel
			text : qsTr("Right Hand")
			font.pointSize : 12
			anchors.left : rightHandBox.right
			anchors.top : textLabel.bottom
			anchors.leftMargin : 10
			anchors.topMargin : 10
		}

		Label {
			id : leftHandLabel
			text : qsTr("Left Hand")
			font.pointSize : 12
			anchors.left : leftHandBox.right
			anchors.top : rightHandLabel.bottom
			anchors.leftMargin : 10
			anchors.topMargin : 10
		}

		CheckBox {
			id : rightHandBox
			checked: true
			anchors.left : window.left
			anchors.top : textLabel.bottom
			anchors.leftMargin : 10
			anchors.topMargin : 10
			onClicked : playStaff(rightHandStaffIdx, this.checked);
		}

		CheckBox {
			id : leftHandBox
			checked: true
			anchors.left : window.left
			anchors.top : rightHandBox.bottom
			anchors.leftMargin : 10
			anchors.topMargin : 10
			onClicked : playStaff(leftHandStaffIdx, this.checked);
		}
	}
}