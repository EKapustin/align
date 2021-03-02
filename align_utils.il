;
;	$Source: align_utils.il $ $Revision: 21:b82ac9494a26 $ $Branch$ $Rev: 21 $
;	$Author: Kapustin $ $Date: 2011-06-05 00:46 +0300 $
;
;	skill load "o:\\Sripts\\align\\align_utils.il"

;
; Get the point snapped to the nearest grid (if snapToGrid mode is true).
;
defun( griddedPoint (point)
	let( (snapToGrid grp)
;		if( _formData
;			then
				snapToGrid = _formData->snapToGrid
;			else snapToGrid = t
;		)
		axlEnterPoint( ?points list( point) ?gridSnap snapToGrid)
	)
);defun

;
; Get maximum X coordinate from list of objects
;
defun( maxX (lObjects)
	let( (obj ptX result)
		result = -1000000.0
		foreach( obj lObjects
			ptX = xCoord(getObjectLocation(obj))
			result = max(ptX result)
		)
		result
	)
);defun

;
; Get minimum X coordinate from list of objects
;
defun( minX (lObjects)
	let( (obj ptX result)
		result = 1000000.0
		foreach( obj lObjects
			ptX = xCoord(getObjectLocation(obj))
			result = min(ptX result)
		)
		result
	)
);defun

;
; Get maximum Y coordinate from list of objects
;
defun( maxY (lObjects)
	let( (obj ptY result)
		result = -1000000.0
		foreach( obj lObjects
			ptY = yCoord(getObjectLocation(obj))
			result = max(ptY result)
		)
		result
	)
);defun

;
; Get minimum Y coordinate from list of objects
;
defun( minY (lObjects)
	let( (obj ptY result)
		result = 1000000.0
		foreach( obj lObjects
			ptY = yCoord(getObjectLocation(obj))
			result = min(ptY result)
		)
		result
	)
);defun

;
; Sort list of objects by X coordinate, ascending order.
;
defun( orderByX (objectList)
	sort( objectList 'comparePositionX )
);defun
defun( comparePositionX ( obj1 obj2 )
	let( ( pt1x pt2x pt1y pt2y pt1 pt2 result)
		pt1 = getObjectLocation(obj1)
		pt2 = getObjectLocation(obj2)
		pt1x = xCoord( pt1 )
		pt2x = xCoord( pt2 )
		if( (pt1x < pt2x)
			then result = t
			else
				if( (pt1x == pt2x)
					then
						; aditionaly compare by Y
						pt1y = yCoord( pt1 )
						pt2y = yCoord( pt2 )
						if( (pt1y < pt2y)
							then result = t
							else result = nil
						)
					else result = nil
				)
		)
		result
	) ; let
) ; defun

;
; Sort list of objects by Y coordinate, ascending order.
;
defun( orderByY (objectList)
	sort( objectList 'comparePositionY )
);defun
defun( comparePositionY ( obj1 obj2 )
	let( ( pt1x pt2x pt1y pt2y pt1 pt2 result)
		pt1 = getObjectLocation(obj1)
		pt2 = getObjectLocation(obj2)
		pt1y = yCoord( pt1 )
		pt2y = yCoord( pt2 )
		if( (pt1y < pt2y)
			then result = t
			else
				if( (pt1y == pt2y)
					then
						; aditionaly compare by X
						pt1x = xCoord( pt1 )
						pt2x = xCoord( pt2 )
						if( (pt1x < pt2x)
							then result = t
							else result = nil
						)
					else result = nil
				)
		)
		result
	) ; let
) ; defun

;
; Get object location point according to selected mode (Origin, Body Center, Pin)
;
defun( getObjectLocation (object)
	let( ( result)
		case( _formData->snapPoint
			( "origin" result = axlDBAltOrigin('origin object) )
			( "center" result = axlDBAltOrigin('center object) )
			( "pin" result = axlDBAltOrigin('pin1 object) )
		);case
		result
	) ; let
) ; defun

;
; Get object boundary box.
; First trying get Dfa_Bound_Top(Bottom)
; if Dfa not present trying Place_Bound_Top(Bottom)
; if Place not present get bBox property.
;
defun( getObjectBBox (object)
	let( ( objectChildren child dfaLayer placeLayer result)
		if(object->isMirrored
			then dfaLayer = "PACKAGE GEOMETRY/DFA_BOUND_BOTTOM" placeLayer = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"
			else dfaLayer = "PACKAGE GEOMETRY/DFA_BOUND_TOP" placeLayer = "PACKAGE GEOMETRY/PLACE_BOUND_TOP"
		)
		objectChildren = object->children
		; only Symbols have objectChildren
		if(objectChildren then
			; find Dfa_Bound_ shape
			foreach( child objectChildren
				if((child->objType == "shape" && child->layer == dfaLayer) then
					result = child->bBox
				)
			)
			; find Place_Bound_ shape
			if(!result then
				foreach( child objectChildren
					if((child->objType == "shape" && child->layer == placeLayer) then
						result = child->bBox
					)
				)
			)
		)
		if(!result then result = object->bBox)
		result
	) ; let
) ; defun

;
; Get objects boundary boxes.
; Return list of boxes.
;
defun( getBBoxes (objectList)
	let( ( object result)
		foreach( object objectList
			result = tconc(result getObjectBBox(object))
		)
		car(result) ; get list from "tconc" list
	) ; let
) ; defun

;
; Get minimal X boundary box coordinate for given BBoxes.
;
defun( getMinBBoxX (boxList)
	let( ( ptX box result)
		result = 1000000.0
		foreach( box boxList
			ptX = xCoord(car(box))
			result = min(ptX result)
		)
		result
	) ; let
) ; defun

;
; Get maximal X boundary box coordinate for given BBoxes.
;
defun( getMaxBBoxX (boxList)
	let( ( ptX box result)
		result = -1000000.0
		foreach( box boxList
			ptX = xCoord(cadr(box))
			result = max(ptX result)
		)
		result
	) ; let
) ; defun

;
; Get minimal Y boundary box coordinate for given BBoxes.
;
defun( getMinBBoxY (boxList)
	let( ( ptY box result)
		result = 1000000.0
		foreach( box boxList
			ptY = yCoord(car(box))
			result = min(ptY result)
		)
		result
	) ; let
) ; defun

;
; Get maximal X boundary box coordinate for given BBoxes.
;
defun( getMaxBBoxY (boxList)
	let( ( ptY box result)
		result = -1000000.0
		foreach( box boxList
			ptY = yCoord(cadr(box))
			result = max(ptY result)
		)
		result
	) ; let
) ; defun

defun( refreshIDs (objectList)
	let( ( object resultList)
		foreach( object objectList
			resultList = tconc(resultList axlDBRefreshId(object))
		)
		car(resultList) ; get list from "tconc" list
	) ; let
) ; defun

;
; Check for object have "Fixed" property. If it's true, remove this object from selection.
; Return list without fixed objects.
;
defun( checkForFixedObjects (objectList)
	let( ( x prop object resultList)
		foreach( object objectList
			prop = axlDBGetProperties(object '("allegro"))
			if(exists( x prop (x == '(FIXED t)))
				; remove from selection
				then axlSubSelectObject(object)
				; place to returned list
				else resultList = tconc(resultList object)
			)
		)
		car(resultList) ; get list from "tconc" list
	) ; let
) ; defun


