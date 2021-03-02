;
;	$Source: align_do.il $ $Revision: 10:ce9f781028bc $ $Branch$ $Rev: 10 $
;	$Author: Kapustin $ $Date: 2011-05-31 01:48 +0300 $
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
		xyPoint = griddedPoint( list( 0 fixedYPoint))
		fixedYPoint = yCoord(xyPoint)
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
		xyPoint = griddedPoint( list( fixedXPoint 0))
		fixedXPoint = xCoord(xyPoint)
		foreach( oItem _selectedObjects
			xPoint = xCoord(getObjectLocation(oItem))
			deltaX = fixedXPoint - xPoint
			deltaPoint = list( deltaX 0 )
			axlTransformObject( oItem ?move deltaPoint)
		)
	)
);end-fun

defun( onDistributeH ()
	axlMsgPut("Distribute horizontally")
	axlFinishEnterFun()
	; get propely ordered list of selected ojects
	_selectedObjects = orderByX(axlGetSelSet())
	; check for use step provided in form
	if( _formData->useStepH
		then _handler = 'doDistributeByStepH
		else _handler = 'doDistributeH
	)
);end-fun
defun( doDistributeH ()
	let( (leftX rightX step xyPoint)
;		axlMsgPut("doDistributeH")
		; calculate step
		leftX = xCoord(getObjectLocation(car(_selectedObjects)))
		rightX = xCoord(getObjectLocation(car(last(_selectedObjects))))
		step = (rightX-leftX)/(length(_selectedObjects)-1)
		; snap step to grid (depending from _formData->snapToGrid)
		xyPoint = griddedPoint( list( step 0))
		step = xCoord(xyPoint)
		; update form
		putprop( _formData step 'stepH)
		(axlFormSetField _formPtr "fStepH" step)
		doDistributeByStepH()
	)
);end-fun
defun( doDistributeByStepH ()
	let( (i step)
;		axlMsgPut("doDistributeByStepH")
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

defun( onDistributeV ()
	axlMsgPut("Distribute vertically")
	axlFinishEnterFun()
	_selectedObjects = orderByY(axlGetSelSet())
	if( _formData->useStepV
		then _handler = 'doDistributeByStepV
		else _handler = 'doDistributeV
	)
);end-fun
defun( doDistributeV ()
	let( (leftX rightX step xyPoint)
;		axlMsgPut("doDistributeV")
		; calculate step
		botY = yCoord(getObjectLocation(car(_selectedObjects)))
		topY = yCoord(getObjectLocation(car(last(_selectedObjects))))
		step = (topY-botY)/(length(_selectedObjects)-1)
		; snap step to grid (depending from _formData->snapToGrid)
		xyPoint = griddedPoint( list( 0 step))
		step = yCoord(xyPoint)
		; update form
		putprop( _formData step 'stepV)
		(axlFormSetField _formPtr "fStepV" step)
		doDistributeByStepV()
	)
);end-fun
defun( doDistributeByStepV ()
	let( (i step)
;		axlMsgPut("doDistributeByStepV")
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


