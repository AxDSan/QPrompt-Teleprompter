/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

import QtQuick 2.15
import QtQuick.Window 2.15

// External Windows
Window {
    id: projectionWindow
    title: i18n("Projection Window")
    //transientParent: parent.parent
    //transientParent: null
    visible: true
    color: "transparent"

    width: viewport.width; height: viewport.height
    
    ShaderEffectSource {
        width: parent.width; height: parent.height
        sourceItem: viewport
        //sourceItem: layerOfLayer
        hideSource: false

        mipmap: true
        samples: 4
        smooth: true
    }
}
