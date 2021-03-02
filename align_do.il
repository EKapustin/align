;
;	$Source: align_do.il $ $Revision: 43:7a6ba9c5fe59 $ $Branch$ $Rev: 43 $
;	$Author: Kapustin $ $Date: 2011-07-13 00:09 +0300 $
;
;	files required:  align_utils.il
;
;	skill load "o:\\Sripts\\align\\align_do.il"

defun( onTop ()
	axlMsgPut("Align by TOP boundary")
	_handler = 'doTop
	axlCancelEnterFun()
);end-fun
defun( doTop ()
		axlDBCloak( 'doMoveTop() 'shape )
);end-fun
defun( doMoveTop ()
	let( (lBBoxes maxY i objectItem boxItem boxY objectY griddedY deltaY deltaPoint grids)
		lBBoxes = getBBoxes(_selectedObjects)
		maxY = getMaxBBoxY(lBBoxes)
		grids = getCurrentGrid(_selectedObjects)
		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxY = yCoord(cadr(boxItem))
			deltaY = maxY - boxY

			objectY = yCoord(getObjectLocation(objectItem))	; irginal point
			griddedY = yCoord(griddedPoint(list( 0 (objectY + deltaY) ) grids)) ; moved and snapped point

			deltaY = griddedY - objectY
			deltaPoint = list( 0 deltaY)
			moveObject( objectItem deltaPoint)

		)
	);end-let
);end-fun

defun( onBottom ()
	axlMsgPut("Align by BOTTOM boundary")
	axlFinishEnterFun()
	_handler = 'doBottom
);end-fun
defun( doBottom ()
	axlDBCloak( 'doMoveBottom() 'shape )
);end-fun
defun( doMoveBottom ()
	let( (lBBoxes minY i objectItem boxItem boxY objectY griddedY deltaY deltaPoint grids)
		lBBoxes = getBBoxes(_selectedObjects)
		minY = getMinBBoxY(lBBoxes)
		grids = getCurrentGrid(_selectedObjects)
		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxY = yCoord(car(boxItem))
			deltaY = minY - boxY

			objectY = yCoord(getObjectLocation(objectItem))
			griddedY = yCoord(griddedPoint(list( 0 (objectY + deltaY) ) grids))

			deltaY = griddedY - objectY
			deltaPoint = list( 0 deltaY )
			moveObject( objectItem deltaPoint)
		)
	);end-let
);end-fun

defun( onLeft ()
	axlMsgPut("Align by LEFT boundary")
	axlFinishEnterFun()
	_handler = 'doLeft
);end-fun
defun( doLeft ()
	axlDBCloak( 'doMoveLeft() 'shape )
);end-fun
defun( doMoveLeft ()
	let( (lBBoxes minX i objectItem boxItem boxX objectX griddedX deltaX deltaPoint grids)
		lBBoxes = getBBoxes(_selectedObjects)
		minX = getMinBBoxX(lBBoxes)
		grids = getCurrentGrid(_selectedObjects)
		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxX = xCoord(car(boxItem))
			deltaX = minX - boxX

			objectX = xCoord(getObjectLocation(objectItem))
			griddedX = xCoord(griddedPoint(list( (objectX + deltaX) 0 ) grids))

			deltaX = griddedX - objectX
			deltaPoint = list( deltaX 0 )
			moveObject( objectItem deltaPoint)
		)
	);end-let
);end-fun

defun( onRight ()
	axlMsgPut("Align by RIGHT boundary")
	axlFinishEnterFun()
	_handler = 'doRight
);end-fun
defun( doRight ()
	axlDBCloak( 'doMoveRight() 'shape )
);end-fun
defun( doMoveRight ()
	let( (lBBoxes maxX i objectItem boxItem boxX objectX griddedX gridCorrection deltaX deltaPoint grids)
		lBBoxes = getBBoxes(_selectedObjects)
		maxX = getMaxBBoxX(lBBoxes)
		grids = getCurrentGrid(_selectedObjects)
		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxX = xCoord(cadr(boxItem))
			deltaX = maxX - boxX

			objectX = xCoord(getObjectLocation(objectItem))
			griddedX = xCoord( griddedPoint( list( (objectX + deltaX) 0 ) grids ) )

			deltaX = griddedX - objectX
			deltaPoint = list( deltaX 0 )
			moveObject( objectItem deltaPoint)
		)
	);end-let
);end-fun

defun( onCenterH ()
	axlMsgPut("Align horizontally")
	; assign handler function
	; call handler after exit from axlSelect()
	; otherwise snap to grid not properly work in axlEnterPoint() function
	_handler = 'doCenterH
	; exite from axlSelect()
	axlFinishEnterFun()
);end-fun
defun( doCenterH ()
	let( (maxY minY fixedPointY pointY)
		maxY = maxY(_selectedObjects)
		minY = minY(_selectedObjects)
		fixedPointY = (maxY-minY)/2 + minY ; зафиксировать Y координату
		; move objects
		axlDBCloak( 'moveToHorizontal(fixedPointY) 'shape )
	);end-let
);end-fun
defun( moveToHorizontal (fixedPointY)
	let( (deltaY deltaPoint pointY grids)
		; snap to grid (depend on _formData->snapToGrid)
		grids = getCurrentGrid(_selectedObjects)
		fixedPointY = yCoord(griddedPoint( list( 0 fixedPointY) grids))
		foreach( oItem _selectedObjects
			pointY = yCoord(getObjectLocation(oItem))
			deltaY = fixedPointY - pointY
			deltaPoint = list( 0 deltaY)
			moveObject( oItem deltaPoint)
		)
	);end-let
);end-fun

defun( onCenterV ()
	axlMsgPut("Align vertically")
	axlFinishEnterFun()
	_handler = 'doCenterV
);end-fun
defun( doCenterV ()
	let( (maxX minX fixedPointX)
		maxX = maxX(_selectedObjects)
		minX = minX(_selectedObjects)
		fixedPointX = (maxX-minX)/2 + minX
		axlDBCloak( 'moveToVertical(fixedPointX) 'shape )
	);end-let
);end-fun
defun( moveToVertical (fixedPointX)
	let( (deltaX deltaPoint pointX grids)
		; snap to grid (depend on _formData->snapToGrid)
		grids = getCurrentGrid(_selectedObjects)
		fixedPointX = xCoord(griddedPoint( list( fixedPointX 0) grids))
		foreach( oItem _selectedObjects
			pointX = xCoord(getObjectLocation(oItem))
			deltaX = fixedPointX - pointX
			deltaPoint = list( deltaX 0 )
			moveObject( oItem deltaPoint)
		)
	);end-let
);end-fun

; -------------------- Distribute -------------------------------------
defun( onDistributeH ()
	axlMsgPut("Distribute horizontally")
	; get propely ordered list of selected ojects
	_selectedObjects = orderByX(_selectedObjects)
	; check mode
	if( _formData->useGap
		then _handler = 'doCalcStepBetweenBoundaryH
		else _handler = 'doCalcStepH
	)
	axlFinishEnterFun()
);end-fun
defun( doCalcStepH ()
	let( (leftX rightX step grids)
when( (axlIsDebug) axlMsgPut("doCalcStepH"))
		; check for step provided in form
		if( !_formData->useStepH then
			; calculate step
			leftX = xCoord(getObjectLocation(car(_selectedObjects)))
			rightX = xCoord(getObjectLocation(car(last(_selectedObjects))))
			step = (rightX-leftX)/(length(_selectedObjects)-1)
			; snap step to grid (depending from _formData->snapToGrid)
			grids = getCurrentGrid(_selectedObjects)
			step = xCoord(griddedPoint( list( step 0) grids))
			; update form
			_formData->stepH = step
			(axlFormSetField _formPtr "fStepH" step)
		)
;		axlShell("cputime start")
;		axlShell("cputime reset")
		axlDBCloak( 'doDistributeH() 'shape )
;		doDistributeH()
;		axlShell("cputime stop")
	);end-let
);end-fun
defun( doDistributeH ()
	let( (i step pointX deltaX deltaPoint grids)
when( (axlIsDebug) axlMsgPut("doDistributeH"))
		grids = getCurrentGrid(_selectedObjects)
		i = xCoord(griddedPoint(getObjectLocation(car(_selectedObjects)) grids))
		step = _formData->stepH
		foreach( oItem _selectedObjects
			pointX = xCoord(getObjectLocation(oItem))
			deltaX = i - pointX
			deltaPoint = list( deltaX 0 )
			moveObject( oItem deltaPoint)
			i = i + step
		)
	);end-let
);end-fun

defun( doCalcStepBetweenBoundaryH ()
	let( (leftX prevX box lBox gap step grids)
when( (axlIsDebug) axlMsgPut("doCalcStepBetweenBoundaryH"))
		; check for step provided in form
		if( !_formData->useStepH then
			gap = 0.0
			; get left boundary for first object
			prevX = xCoord(car(getObjectBBox(car(_selectedObjects))))
			; calculate common gap
			lBox = getBBoxes(_selectedObjects)
			foreach( box lBox
				; get left boundary
				leftX = xCoord(car(box))
				gap = gap + leftX - prevX
				; get right boundary for next iteration
				prevX = xCoord(cadr(box))
			)
			; calculate step
			step = gap/(length(_selectedObjects)-1)
			; snap step to grid
			grids = getCurrentGrid(_selectedObjects)
			step = xCoord(griddedPoint( list( step 0 ) grids))
			_formData->stepH = step
			; update form
			axlFormSetField(_formPtr "fStepH" step)
		)
;		axlShell("cputime start")
;		axlShell("cputime reset")
		axlDBCloak( 'doDistributeGapBetweenBoundaryH() 'shape )
;		doDistributeGapBetweenBoundaryH()
;		axlShell("cputime stop")
	);end-let
);end-fun
defun( doDistributeGapBetweenBoundaryH ()
	let( (step prevX oItem box leftX rightX deltaX currX destX deltaPoint grids)
when( (axlIsDebug) axlMsgPut("doDistributeGapBetweenBoundaryH"))
		step = _formData->stepH
		; get left boundary for first object
		prevX = xCoord(car(getObjectBBox(car(_selectedObjects)))) - step
		grids = getCurrentGrid(_selectedObjects)
		foreach( oItem _selectedObjects
			; current boundary
			box = getObjectBBox(oItem)
			leftX = xCoord(car(box))
			rightX = xCoord(cadr(box))
			deltaX = leftX - prevX - step

			; curent location
			currX = xCoord(oItem->xy)
			; destination location (grided)
			destX = xCoord(griddedPoint(list( (currX - deltaX) 0 ) grids))
			deltaPoint = list( (destX - currX) 0 )
			moveObject(oItem deltaPoint)
			prevX = prevX + step + (rightX - leftX)
		)
	);end-let
);end-fun

defun( onDistributeV ()
	axlMsgPut("Distribute vertically")
	_selectedObjects = orderByY(_selectedObjects)
	if( _formData->useGap
		then _handler = 'doCalcStepBetweenBoundaryV
		else _handler = 'doCalcStepV
	)
	axlFinishEnterFun()
);end-fun
defun( doCalcStepV ()
	let( (botY topY step grids)
when( (axlIsDebug) axlMsgPut("doCalcStepV"))
		if( !_formData->useStepV then
			; calculate step
			botY = yCoord(getObjectLocation(car(_selectedObjects)))
			topY = yCoord(getObjectLocation(car(last(_selectedObjects))))
			step = (topY-botY)/(length(_selectedObjects)-1)
			; snap step to grid (depending from _formData->snapToGrid)
			grids = getCurrentGrid(_selectedObjects)
			step = yCoord(griddedPoint( list( 0 step) grids))
			; update form
			_formData->stepV = step
			(axlFormSetField _formPtr "fStepV" step)
		)
		axlDBCloak( 'doDistributeV() 'shape )
	);end-let
);end-fun
defun( doDistributeV ()
	let( (i step pointY deltaY deltaPoint grids)
when( (axlIsDebug) axlMsgPut("doDistributeV"))
		grids = getCurrentGrid(_selectedObjects)
		i = yCoord(griddedPoint(getObjectLocation(car(_selectedObjects)) grids))
		step = _formData->stepV
		foreach( oItem _selectedObjects
			pointY = yCoord(getObjectLocation(oItem))
			deltaY = i - pointY
			deltaPoint = list( 0 deltaY )
			moveObject( oItem deltaPoint)
			i = i + step
		)
	);end-let
);end-fun

defun( doCalcStepBetweenBoundaryV ()
	let( (bottomY prevY box lBox gap step grids)
when( (axlIsDebug) axlMsgPut("doCalcStepBetweenBoundaryV"))
		if( !_formData->useStepV then
			gap = 0.0
			; get left boundary for first object
			prevY = yCoord(car(getObjectBBox(car(_selectedObjects))))
			; calculate common gap
			lBox = getBBoxes(_selectedObjects)
			foreach( box lBox
				; get left boundary
				bottomY = yCoord(car(box))
				gap = gap + bottomY - prevY
				; get right boundary for next iteration
				prevY = yCoord(cadr(box))
			)
			; calculate step
			step = gap/(length(_selectedObjects)-1)
			; snap step to grid
			grids = getCurrentGrid(_selectedObjects)
			step = yCoord(griddedPoint( list( 0 step) grids))
			_formData->stepV = step
			; update form
			(axlFormSetField _formPtr "fStepV" step)
		)
		axlDBCloak( 'doDistributeGapBetweenBoundaryV() 'shape )
	);end-let
);end-fun
defun( doDistributeGapBetweenBoundaryV ()
	let( (step prevY oItem box bottomY topY deltaY currY destY deltaPoint grids)
when( (axlIsDebug) axlMsgPut("doDistributeGapBetweenBoundaryH"))
		step = _formData->stepV
		; get bottom boundary for first object
		prevY = yCoord(car(getObjectBBox(car(_selectedObjects)))) - step
		grids = getCurrentGrid(_selectedObjects)
		foreach( oItem _selectedObjects
			; current boundary
			box = getObjectBBox(oItem)
			bottomY = yCoord(car(box))
			topY = yCoord(cadr(box))
			deltaY = bottomY - prevY - step

			; curent location
			currY = yCoord(oItem->xy)
			; destination location (grided)
			destY = yCoord(griddedPoint(list( 0 (currY - deltaY) ) grids))
			deltaPoint = list( 0 (destY - currY) )
			moveObject( oItem deltaPoint )
			prevY = prevY + step + (topY - bottomY)
		)
	);end-let
);end-fun

; -------------------- Pick -------------------------------------
defun( onPickH ()
	axlMsgPut("Pick horizontally")
	axlFinishEnterFun()
	_handler = 'doPickH
);end-fun
defun( doPickH ()
	let( (fixedObject fixedPoint fixedPointY grids)
		fixedPoint = nil
		if( _formData->usePickH
		then
			fixedPointY = _formData->pickH
		else
			fixedPoint = axlEnterPoint(?prompts "Select an object or point")
			if( fixedPoint then ;nil if pressed Oops
				axlSingleSelectPoint(fixedPoint)
				fixedObject = axlGetSelSet()
				if( fixedObject
				then
					fixedPointY = yCoord(getObjectLocation(car(fixedObject)))
				else
					fixedPointY = yCoord(fixedPoint)
				)
			)
		)
		if( fixedPointY then ; nil if pressed Oops
			; snap to grid (depend on _formData->snapToGrid)
			grids = getCurrentGrid(_selectedObjects)
			fixedPointY = yCoord(griddedPoint( list( 0 fixedPointY) grids))
			_formData->pickH = fixedPointY
			axlFormSetField(_formPtr "fPickH" fixedPointY)
			; move objects
			axlDBCloak( 'moveToHorizontal(fixedPointY) 'shape )
		)
	);end-let
);end-fun

defun( onPickV ()
	axlMsgPut("Pick horizontally")
	axlFinishEnterFun()
	_handler = 'doPickV
);end-fun
defun( doPickV ()
	let( (fixedObject fixedPoint fixedPointX grids)
		fixedPoint = nil
		if( _formData->usePickV
		then
			fixedPointX = _formData->pickV
		else
			fixedPoint = axlEnterPoint(?prompts "Select an object or point")
			if( fixedPoint then ;nil if pressed Oops
				axlSingleSelectPoint(fixedPoint)
				fixedObject = axlGetSelSet()
				if( fixedObject
				then
					fixedPointX = xCoord(getObjectLocation(car(fixedObject)))
				else
					fixedPointX = xCoord(fixedPoint)
				)
			)
		)
		if( fixedPointX then ; nil if pressed Oops
			grids = getCurrentGrid(_selectedObjects)
			fixedPointX = xCoord(griddedPoint( list( fixedPointX 0) grids))
			_formData->pickV = fixedPointX
			axlFormSetField(_formPtr "fPickV" fixedPointX)
			axlDBCloak( 'moveToVertical(fixedPointX) 'shape )
		)
	);end-let
);end-fun

