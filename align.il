;
;	$Source: align.il $ $Revision: 10:ce9f781028bc $ $Branch$ $Rev: 10 $
;	$Author: Kapustin $ $Date: 2011-05-31 01:48 +0300 $
;
;	Files required:	align_do.il
;					align_utils.il
;					align.form
;					align-bottom.bmp
;					align-centerH.bmp
;					align-centerV.bmp
;					align-left.bmp
;					align-right.bmp
;					align-top.bmp
;					distributeH.bmp
;					distributeV.bmp
;	Place form and bitmap files to %formpath%.
;
;	skill load "o:\\Sripts\\align\\align_utils.il"
; 	skill load "o:\\Sripts\\align\\align_do.il"
;	skill load "o:\\Sripts\\align\\align.il"

axlCmdRegister( "align" 'align )
axlUIMenuRegister( "move" '( ("&Align" "align") ) )


procedure( align( )
(prog (aliasForSystemDone)
	when( axlOKToProceed()
		axlClearSelSet()
		initGlobalVariable()
		initForm()

		popupA = axlUIPopupDefine( nil
				(list
					(list "Done" 'alignDone)
				))
		axlUIPopupSet( popupA )

		axlSetFindFilter(?enabled '(GROUPS SYMBOLS PINS VIAS TEXT NAMEFORM ) ?onButtons _filterOnButtons) ; установить фильтр
		axlMsgPut("Select object(s)")
		while( _finish == nil
			; wait for object selection
			axlSelect(?groupMode nil ?prompt nil)
			if(_selectedObjects then axlMsgPut("Choose action"))
			; execute operation selected in form
			if(_handler then
				if(_selectedObjects
					then
						funcall(_handler)
						; refresh id
						axlDBRefreshId(axlGetSelSet())
						; restore selection
						_selectedObjects = refreshIDs(_selectedObjects)
						axlAddSelectObject(_selectedObjects)
					else
						axlMsgPut("No object(s) found")
				)
				_handler = nil
			)

		);end-while
	);endwhen
);end-prog
);endprocedure

;----------------- DONE Call--------------------------------
defun( alignDone ()
	(prog ()
		_finish = t
		axlFormClose(_formPtr)
		axlDehighlightObject(_selectedObjects)
		axlCancelEnterFun()
		axlClearSelSet()
;		axlCloseFindFilter()
		axlUIPopupSet( nil)
		_filterOnButtons = axlGetFindFilter(t)
	)
);end-fun

;-------------------Parameter form data ------------------
defun( initForm () ;
;	axlMsgPut("initForm")
	_formPtr = axlMiniStatusLoad( (gensym) "align.form" '_parmCallBack)
	;_formPtr = axlFormCreate( (gensym) "align.form" '(ne canvas msglines 0) '_parmCallBack t)
	if( ( _formData == nil ) then
		_formData = t
		(axlFormSetField _formPtr "bxSnapToGrid" t)
		putprop( _formData t 'snapToGrid)
		(axlFormSetField _formPtr "bxStepH" nil)
		putprop( _formData nil 'useStepH)
		(axlFormSetField _formPtr "bxStepV" nil)
		putprop( _formData nil 'useStepV)
		(axlFormSetField _formPtr "fStepH" 100.0)
		putprop( _formData 100.0 'stepH)
		(axlFormSetField _formPtr "fStepV" 100.0)
		putprop( _formData 100.0 'stepV)
		(axlFormSetField _formPtr "cmbSnapPoint" "origin")
		putprop( _formData "origin" 'snapPoint)
		(axlFormSetField _formPtr "rbMode1" t)
		(axlFormSetField _formPtr "rbMode2" nil)
		putprop( _formData "align" 'currentMode)
	else
		(axlFormSetField _formPtr "bxSnapToGrid" _formData->snapToGrid)
		(axlFormSetField _formPtr "bxStepH" _formData->useStepH)
		(axlFormSetField _formPtr "bxStepV" _formData->useStepV)
		(axlFormSetField _formPtr "fStepH" _formData->stepH)
		(axlFormSetField _formPtr "fStepV" _formData->stepV)
		(axlFormSetField _formPtr "cmbSnapPoint" _formData->snapPoint)
		case(_formData->currentMode
			("align"
				(axlFormSetField _formPtr "rbMode1" t)
				(axlFormSetField _formPtr "rbMode2" nil)
			)
			("distribute"
				(axlFormSetField _formPtr "rbMode1" nil)
				(axlFormSetField _formPtr "rbMode2" t)
			)
		)
	)

	if(_formData->useStepH
		then axlFormSetFieldEditable(_formPtr "fStepH" t)
		else axlFormSetFieldEditable(_formPtr "fStepH" nil)
	)
	if(_formData->useStepV
		then axlFormSetFieldEditable(_formPtr "fStepV" t)
		else axlFormSetFieldEditable(_formPtr "fStepV" nil)
	)
	; icons
	initFormThumbnails()
	switchForm(nil)
;	axlFormDisplay(_formPtr)
);end-defun
defun( initFormThumbnails ()
	(prog (formPathList formPath)
		formPathList = axlGetVariableList("formpath");
		foreach( path formPathList
			if(isFile(concat(path "/align-top.bmp")) then
				formPath = path
			)
		)
		if(formPath then
			axlFormSetField(_formPtr, "align-top", concat(formPath "/align-top.bmp"))
			axlFormSetField(_formPtr, "align-bottom", concat(formPath "/align-bottom.bmp"))
			axlFormSetField(_formPtr, "align-centerH", concat(formPath "/align-centerH.bmp"))
			axlFormSetField(_formPtr, "align-centerV", concat(formPath "/align-centerV.bmp"))
			axlFormSetField(_formPtr, "align-left", concat(formPath "/align-left.bmp"))
			axlFormSetField(_formPtr, "align-right", concat(formPath "/align-right.bmp"))
			axlFormSetField(_formPtr, "distributeH", concat(formPath "/distributeH.bmp"))
			axlFormSetField(_formPtr, "distributeV", concat(formPath "/distributeV.bmp"))
		)
	)
);end-defun
defun( switchForm (mode)
;	axlMsgPut("switchForm")
	if(!mode then
		if(_formData
			then mode = _formData->currentMode
			else mode = "align"
		)
	)
	case( mode
		("align"
			axlFormSetFieldVisible( _formPtr "align-top" 1)
			axlFormSetFieldVisible( _formPtr "bnTop" 1)
			axlFormSetFieldVisible( _formPtr "align-centerH" 1)
			axlFormSetFieldVisible( _formPtr "bnCenterH" 1)
			axlFormSetFieldVisible( _formPtr "align-bottom" 1)
			axlFormSetFieldVisible( _formPtr "bnBottom" 1)

			axlFormSetFieldVisible( _formPtr "align-left" 1)
			axlFormSetFieldVisible( _formPtr "bnLeft" 1)
			axlFormSetFieldVisible( _formPtr "align-centerV" 1)
			axlFormSetFieldVisible( _formPtr "bnCenterV" 1)
			axlFormSetFieldVisible( _formPtr "align-right" 1)
			axlFormSetFieldVisible( _formPtr "bnRight" 1)

			axlFormSetFieldVisible( _formPtr "bxStepH" 0)
			axlFormSetFieldVisible( _formPtr "fStepH" 0)
			axlFormSetFieldVisible( _formPtr "distributeH" 0)
			axlFormSetFieldVisible( _formPtr "bnDistributeH" 0)

			axlFormSetFieldVisible( _formPtr "bxStepV" 0)
			axlFormSetFieldVisible( _formPtr "fStepV" 0)
			axlFormSetFieldVisible( _formPtr "distributeV" 0)
			axlFormSetFieldVisible( _formPtr "bnDistributeV" 0)
		)
		("distribute"
			axlFormSetFieldVisible( _formPtr "align-top" 0)
			axlFormSetFieldVisible( _formPtr "bnTop" 0)
			axlFormSetFieldVisible( _formPtr "align-centerH" 0)
			axlFormSetFieldVisible( _formPtr "bnCenterH" 0)
			axlFormSetFieldVisible( _formPtr "align-bottom" 0)
			axlFormSetFieldVisible( _formPtr "bnBottom" 0)

			axlFormSetFieldVisible( _formPtr "align-left" 0)
			axlFormSetFieldVisible( _formPtr "bnLeft" 0)
			axlFormSetFieldVisible( _formPtr "align-centerV" 0)
			axlFormSetFieldVisible( _formPtr "bnCenterV" 0)
			axlFormSetFieldVisible( _formPtr "align-right" 0)
			axlFormSetFieldVisible( _formPtr "bnRight" 0)

			axlFormSetFieldVisible( _formPtr "bxStepH" 1)
			axlFormSetFieldVisible( _formPtr "fStepH" 1)
			axlFormSetFieldVisible( _formPtr "distributeH" 1)
			axlFormSetFieldVisible( _formPtr "bnDistributeH" 1)

			axlFormSetFieldVisible( _formPtr "bxStepV" 1)
			axlFormSetFieldVisible( _formPtr "fStepV" 1)
			axlFormSetFieldVisible( _formPtr "distributeV" 1)
			axlFormSetFieldVisible( _formPtr "bnDistributeV" 1)
		)
	)

);end-defun
;---------------Form Call Back-----------------------------------------------
defun( _parmCallBack (form)
;	axlMsgPut("_parmCallBack")
	case( get(_formPtr 'curField)
		( "rbMode1" switchForm("align") _formData~>currentMode = "align")
		( "rbMode2" switchForm("distribute") _formData~>currentMode = "distribute")
		( "bnTop" onTop() )
		( "bnCenterH" onCenterH() )
		( "bnBottom" onBottom() )
		( "bnLeft" onLeft() )
		( "bnCenterV"  onCenterV() )
		( "bnRight" onRight() )

		("bxStepH"
			_formData~>useStepH = _formPtr->curValue
			if(_formData->useStepH
				then axlFormSetFieldEditable(_formPtr "fStepH" t)
				else axlFormSetFieldEditable(_formPtr "fStepH" nil)
			)
		)
		( "fStepH" _formData~>stepH = _formPtr->curValue )
		( "bnDistributeH" onDistributeH() )
		( "bxStepV"
			_formData~>useStepV = _formPtr->curValue
			if(_formData->useStepV
				then axlFormSetFieldEditable(_formPtr "fStepV" t)
				else axlFormSetFieldEditable(_formPtr "fStepV" nil)
			)
		)
		( "fStepV" _formData~>stepV = _formPtr->curValue )
		( "bnDistributeV" onDistributeV() )
		( "bxSnapToGrid" _formData~>snapToGrid = _formPtr->curValue	)
		( "cmbSnapPoint" _formData~>snapPoint = _formPtr->curValue )
		( "bnDone" alignDone() )
	);case
);end-defun

defun( initGlobalVariable ()
	_finish = nil
	if( !boundp('_formData) _formData = nil)
	_formPtr = nil
	_handler = nil
	_selectedObjects = nil
	if( !boundp('_filterOnButtons) _filterOnButtons ='(SYMBOLS VIAS TEXT))
);end-defun

