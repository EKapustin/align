;
;	$Source: align_do.il $ $Revision: 13:0d163d5c083a $ $Branch$ $Rev: 13 $
;	$Author: Kapustin $ $Date: 2011-05-31 18:48 +0300 $
;
;	files required:  align_utils.il
;
;	skill load "o:\\Sripts\\align\\align_do.il"

defun( onTop ()
	axlMsgPut("Align by TOP boundary")
	_selectedObjects = axlGetSelSet()
	_handler = 'doTop
	axlCancelEnterFun()
);end-fun
defun( doTop ()
	let( (lBBoxes maxY i objectItem boxItem boxY objectY gridY gridCorrection deltaY deltaPoint)
		lBBoxes = getBBoxes(_selectedObjects)
		maxY = getMaxBBoxY(lBBoxes)

		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxY = yCoord(cadr(boxItem))

			objectY = yCoord(getObjectLocation(objectItem))
			gridY = yCoord(griddedPoint(list( 0 objectY)))
			gridCorrection = objectY - gridY

			deltaY = maxY - boxY - gridCorrection
			deltaPoint = list( 0 deltaY)
			axlTransformObject( objectItem ?move deltaPoint)
		)
	)
);end-fun

defun( onBottom ()
	axlMsgPut("Align by BOTTOM boundary")
	axlFinishEnterFun()
	_selectedObjects = axlGetSelSet()
	_handler = 'doBottom
);end-fun
defun( doBottom ()
	let( (lBBoxes minY i objectItem boxItem boxY objectY gridY gridCorrection deltaY deltaPoint)
		lBBoxes = getBBoxes(_selectedObjects)
		minY = getMinBBoxY(lBBoxes)

		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxY = yCoord(car(boxItem))

			objectY = yCoord(getObjectLocation(objectItem))
			gridY = yCoord(griddedPoint(list( 0 objectY )))
			gridCorrection = objectY - gridY

			deltaY = minY - boxY - gridCorrection
			deltaPoint = list( 0 deltaY )
			axlTransformObject( objectItem ?move deltaPoint)
		)

	)
);end-fun

defun( onLeft ()
	axlMsgPut("Align by LEFT boundary")
	axlFinishEnterFun()
	_selectedObjects = axlGetSelSet()
	_handler = 'doLeft
);end-fun
defun( doLeft ()
	let( (lBBoxes minX i objectItem boxItem boxX objectX gridX gridCorrection deltaX deltaPoint)
		lBBoxes = getBBoxes(_selectedObjects)
		minX = getMinBBoxX(lBBoxes)

		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxX = xCoord(car(boxItem))

			objectX = xCoord(getObjectLocation(objectItem))
			gridX = xCoord(griddedPoint(list( objectX 0 )))
			gridCorrection = objectX - gridX

			deltaX = minX - boxX - gridCorrection
			deltaPoint = list( deltaX 0 )
			axlTransformObject( objectItem ?move deltaPoint)
		)
	)
);end-fun

defun( onRight ()
	axlMsgPut("Align by RIGHT boundary")
	axlFinishEnterFun()
	_selectedObjects = axlGetSelSet()
	_handler = 'doRight
);end-fun
defun( doRight ()
	let( (lBBoxes maxX i objectItem boxItem boxX objectX gridX gridCorrection deltaX deltaPoint)
		lBBoxes = getBBoxes(_selectedObjects)
		maxX = getMaxBBoxX(lBBoxes)

		; move objects
		for( i 1 length(_selectedObjects)
			objectItem = nthelem(i _selectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxX = xCoord(cadr(boxItem))

			objectX = xCoord(getObjectLocation(objectItem))
			gridX = xCoord(griddedPoint(list( objectX 0 )))
			gridCorrection = objectX - gridX

			deltaX = maxX - boxX - gridCorrection
			deltaPoint = list( deltaX 0 )
			axlTransformObject( objectItem ?move deltaPoint)
		)
	)
);end-fun

defun( onCenterH ()
	axlMsgPut("Align horizontally")
	; store selected objects
	_selectedObjects = axlGetSelSet()
	; assign handler function
	; call handler after exit from axlSelect()
	; otherwise snap to grid not properly work in axlEnterPoint() function
	_handler = 'doCenterH
	; exite from axlSelect()
	axlFinishEnterFun()
);end-fun
defun( doCenterH ()
	let( (maxY minY fixedYPoint deltaY deltaPoint)
		maxY = maxY(_selectedObjects)
		minY = minY(_selectedObjects)
		fixedYPoint = (maxY-minY)/2 + minY ; зафиксировать Y координату
		; snap to grid (depend on _formData->snapToGrid)
		fixedYPoint = yCoord(griddedPoint( list( 0 fixedYPoint)))
		; move objects
		foreach( oItem _selectedObjects
			yPoint = yCoord(getObjectLocation(oItem))
			deltaY = fixedYPoint - yPoint
			deltaPoint = list( 0 deltaY)
			axlTransformObject( oItem ?move deltaPoint)
		)
	)
);end-fun

defun( onCenterV ()
	axlMsgPut("Align vertically")
	axlFinishEnterFun()
	_selectedObjects = axlGetSelSet()
	_handler = 'doCenterV
);end-fun
defun( doCenterV ()
	let( (maxX minX fixedXPoint deltaX deltaPoint)
		maxX = maxX(_selectedObjects)
		minX = minX(_selectedObjects)
		fixedXPoint = (maxX-minX)/2 + minX
		fixedXPoint = xCoord(griddedPoint( list( fixedXPoint 0)))
		foreach( oItem _selectedObjects
			xPoint = xCoord(getObjectLocation(oItem))
			deltaX = fixedXPoint - xPoint
			deltaPoint = list( deltaX 0 )
			axlTransformObject( oItem ?move deltaPoint)
		)
	)
);end-fun

; -------------------- Distribute -------------------------------------
defun( onDistributeH ()
	axlMsgPut("Distribute horizontally")
	axlFinishEnterFun()
	; get propely ordered list of selected ojects
	_selectedObjects = orderByX(axlGetSelSet())
	; check mode
	if( _formData->useGap
		then
			if( _formData->useStepH
				then _handler = 'doDistributeGapBetweenBoundaryH
				else _handler = 'doCalcStepBetweenBoundaryH
			)
		else
			; check for use step provided in form
			if( _formData->useStepH
				then _handler = 'doDistributeH
				else _handler = 'doCalcStepH
			)
	)

);end-fun
defun( doCalcStepH ()
	let( (leftX rightX step)
;		axlMsgPut("doCalcStepH")
		; calculate step
		leftX = xCoord(getObjectLocation(car(_selectedObjects)))
		rightX = xCoord(getObjectLocation(car(last(_selectedObjects))))
		step = (rightX-leftX)/(length(_selectedObjects)-1)
		; snap step to grid (depending from _formData->snapToGrid)
		step = xCoord(griddedPoint( list( step 0)))
		; update form
		_formData~>stepH = step
		(axlFormSetField _formPtr "fStepH" step)
		doDistributeH()
	)
);end-fun
defun( doDistributeH ()
	let( (i step)
;		axlMsgPut("doDistributeH")
		i = xCoord(griddedPoint(getObjectLocation(car(_selectedObjects))))
		step = _formData->stepH
		foreach( oItem _selectedObjects
			xPoint = xCoord(getObjectLocation(oItem))
			deltaX = i - xPoint
			deltaPoint = list( deltaX 0 )
			axlTransformObject( oItem ?move deltaPoint)
			i = i + step
		)
	)
);end-fun

defun( doCalcStepBetweenBoundaryH ()
	let( (leftX prevX box lBox gap step)
;		axlMsgPut("doCalcStepBetweenBoundaryH")
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
		step = xCoord(griddedPoint( list( step 0 )))
		_formData~>stepH = step

		; update form		
		axlFormSetField(_formPtr "fStepH" step)
		doDistributeGapBetweenBoundaryH()
	)
);end-fun
defun( doDistributeGapBetweenBoundaryH ()
	let( (step prevX oItem box leftX rightX deltaX currX destX deltaPoint)
;		axlMsgPut("doDistributeGapBetweenBoundaryH")
		step = _formData->stepH
		; get left boundary for first object
		prevX = xCoord(car(getObjectBBox(car(_selectedObjects)))) - step
		
		foreach( oItem _selectedObjects
			; current boundary
			box = getObjectBBox(oItem)
			leftX = xCoord(car(box))
			rightX = xCoord(cadr(box))
			deltaX = leftX - prevX - step
			
			; curent location
			currX = xCoord(oItem->xy)
			; destination location (grided)
			destX = xCoord(griddedPoint(list( (currX - deltaX) 0 )))
			
			deltaPoint = list( (destX - currX) 0 )
			axlTransformObject( oItem ?move deltaPoint )
			
			prevX = prevX + step + (rightX - leftX)
		)
	)
);end-fun

defun( onDistributeV ()
	axlMsgPut("Distribute vertically")
	axlFinishEnterFun()
	_selectedObjects = orderByY(axlGetSelSet())
	if( _formData->useGap
		then
			if( _formData->useStepV
				then _handler = 'doDistributeGapBetweenBoundaryV
				else _handler = 'doCalcStepBetweenBoundaryV
			)
		else
			; check for use step provided in form
			if( _formData->useStepV
				then _handler = 'doDistributeV
				else _handler = 'doCalcStepV
			)
	)
);end-fun
defun( doCalcStepV ()
	let( (leftX rightX step)
;		axlMsgPut("doCalcStepV")
		; calculate step
		botY = yCoord(getObjectLocation(car(_selectedObjects)))
		topY = yCoord(getObjectLocation(car(last(_selectedObjects))))
		step = (topY-botY)/(length(_selectedObjects)-1)
		; snap step to grid (depending from _formData->snapToGrid)
		step = yCoord(griddedPoint( list( 0 step)))
		; update form
		_formData~>stepV = step
		(axlFormSetField _formPtr "fStepV" step)
		doDistributeV()
	)
);end-fun
defun( doDistributeV ()
	let( (i step)
;		axlMsgPut("doDistributeV")
		i = yCoord(griddedPoint(getObjectLocation(car(_selectedObjects))))
		step = _formData->stepV
		foreach( oItem _selectedObjects
			yPoint = yCoord(getObjectLocation(oItem))
			deltaY = i - yPoint
			deltaPoint = list( 0 deltaY )
			axlTransformObject( oItem ?move deltaPoint)
			i = i + step
		)
	)
);end-fun

defun( doCalcStepBetweenBoundaryV ()
	let( (bottomY prevY box lBox gap step)
;		axlMsgPut("doCalcStepBetweenBoundaryV")
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
		step = yCoord(griddedPoint( list( 0 step)))
		_formData~>stepV = step

		; update form		
		(axlFormSetField _formPtr "fStepV" step)
		doDistributeGapBetweenBoundaryV()
	)
);end-fun
defun( doDistributeGapBetweenBoundaryV ()
	let( (step prevY oItem box bottomY topY deltaY currY destY deltaPoint)
;		axlMsgPut("doDistributeGapBetweenBoundaryH")
		step = _formData->stepV
		; get bottom boundary for first object
		prevY = yCoord(car(getObjectBBox(car(_selectedObjects)))) - step
		
		foreach( oItem _selectedObjects
			; current boundary
			box = getObjectBBox(oItem)
			bottomY = yCoord(car(box))
			topY = yCoord(cadr(box))
			deltaY = bottomY - prevY - step
			
			; curent location
			currY = yCoord(oItem->xy)
			; destination location (grided)
			destY = yCoord(griddedPoint(list( 0 (currY - deltaY) )))
			
			deltaPoint = list( 0 (destY - currY) )
			axlTransformObject( oItem ?move deltaPoint )
			
			prevY = prevY + step + (topY - bottomY)
		)
	)
);end-fun


