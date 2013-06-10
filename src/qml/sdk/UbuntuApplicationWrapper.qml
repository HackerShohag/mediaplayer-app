/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Application 0.1

Item {
    function switchToShareApplication() {
        console.log("Launching the share application.");
        ApplicationManager.focusFavoriteApplication(ApplicationManager.ShareApplication);
    }

    function switchToCameraApplication() {
        console.log("Launching the camera application.");
        ApplicationManager.focusFavoriteApplication(ApplicationManager.CameraApplication);
    }
}
