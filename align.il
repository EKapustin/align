;
;	$Source: align.il $ $Revision: 14:1c4a6f6ad5f2 $ $Branch$ $Rev: 14 $
;	$Author: Kapustin $ $Date: 2011-05-31 22:51 +0300 $
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
(prog ()
	when( axlOKToProceed()
		axlClearSelSet()
		initGlobalVariable()
		initForm()

		popupA = axlUIPopupDefine( nil
				(list
					(list "Done" 'alignDone)
					(list "Oops" 'alignOops)
					(list "Cancel" 'alignCancel)
				))
		axlUIPopupSet( popupA )

		axlSetFindFilter(?enabled '(GROUPS SYMBOLS PINS VIAS TEXT NAMEFORM ) ?onButtons _filterOnButtons) ; установить фильтр
		axlMsgPut("Select object(s)")
		_transactionMark = axlDBTransactionStart()
		while( _finish == nil
			; wait for object selection
			axlSelect(?groupMode nil ?prompt nil)
			if(_selectedObjects then axlMsgPut("Choose action"))
			; execute operation selected in form
			if(_handler then
				if(_selectedObjects
					then
						axlDBTransactionMark(_transactionMark)
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

;----------------- Menu Call--------------------------------
defun( alignDone ()
	(prog ()
		_finish = t
		axlFormClose(_formPtr)
		axlDehighlightObject(_selectedObjects)
		axlCancelEnterFun()
		axlClearSelSet()
		axlUIPopupSet( nil )
		popupA = nil
		_filterOnButtons = axlGetFindFilter(t)
		axlDBTransactionCommit( _transactionMark )
		_transactionMark = nil
	)
);end-fun
defun( alignOops ()
	axlDBTransactionOops(_transactionMark)
);end-fun
defun( alignCancel ()
	(prog ()
		_finish = t
		axlFormClose(_formPtr)
		axlDehighlightObject(_selectedObjects)
		axlCancelEnterFun()
		axlClearSelSet()
		axlUIPopupSet( nil )
		popupA = nil
		_filterOnButtons = axlGetFindFilter(t)
		axlDBTransactionRollback( _transactionMark )
		_transactionMark = nil
	)
);end-fun

;-------------------Parameter form data ------------------
defun( initForm () ;
;	axlMsgPut("initForm")
	_formPtr = axlMiniStatusLoad( (gensym) "align.form" '_parmCallBack)
	;_formPtr = axlFormCreate( (gensym) "align.form" '(ne canvas msglines 0) '_parmCallBack t)
	if( ( _formData == nil ) then
		_formData = t
		axlFormSetField(_formPtr "bxSnapToGrid" t)
		_formData~>snapToGrid = t
		axlFormSetField(_formPtr "bxGapH" t)
		axlFormSetField(_formPtr "bxGapV" t)
		_formData~>useGap = t
		axlFormSetField(_formPtr "bxStepH" nil)
		_formData~>useStepH = nil
		axlFormSetField(_formPtr "bxStepV" nil)
		_formData~>useStepV = nil
		axlFormSetField(_formPtr "fStepH" 100.0)
		_formData~>stepH = 100.0
		axlFormSetField(_formPtr "fStepV" 100.0)
		_formData~>stepV = 100.0
		axlFormSetField(_formPtr "cmbSnapPoint" "center")
		_formData~>snapPoint = "center"
		axlFormSetField(_formPtr "rbMode1" t)
		axlFormSetField(_formPtr "rbMode2" nil)
		_formData~>currentMode = "align"
	else
		axlFormSetField(_formPtr "bxSnapToGrid" _formData->snapToGrid)
		axlFormSetField(_formPtr "bxGapH" _formData->useGap)
		axlFormSetField(_formPtr "bxGapV" _formData->useGap)
		axlFormSetField(_formPtr "bxStepH" _formData->useStepH)
		axlFormSetField(_formPtr "bxStepV" _formData->useStepV)
		axlFormSetField(_formPtr "fStepH" _formData->stepH)
		axlFormSetField(_formPtr "fStepV" _formData->stepV)
		axlFormSetField(_formPtr "cmbSnapPoint" _formData->snapPoint)
		case(_formData->currentMode
			("align"
				axlFormSetField(_formPtr "rbMode1" t)
				axlFormSetField(_formPtr "rbMode2" nil)
			)
			("distribute"
				axlFormSetField(_formPtr "rbMode1" nil)
				axlFormSetField(_formPtr "rbMode2" t)
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

			axlFormSetFieldVisible( _formPtr "bxGapH" 0)
			axlFormSetFieldVisible( _formPtr "bxStepH" 0)
			axlFormSetFieldVisible( _formPtr "fStepH" 0)
			axlFormSetFieldVisible( _formPtr "distributeH" 0)
			axlFormSetFieldVisible( _formPtr "bnDistributeH" 0)

			axlFormSetFieldVisible( _formPtr "bxGapV" 0)
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

			axlFormSetFieldVisible( _formPtr "bxGapH" 1)
			axlFormSetFieldVisible( _formPtr "bxStepH" 1)
			axlFormSetFieldVisible( _formPtr "fStepH" 1)
			axlFormSetFieldVisible( _formPtr "distributeH" 1)
			axlFormSetFieldVisible( _formPtr "bnDistributeH" 1)

			axlFormSetFieldVisible( _formPtr "bxGapV" 1)
			axlFormSetFieldVisible( _formPtr "bxStepV" 1)
			axlFormSetFieldVisible( _formPtr "fStepV" 1)
			axlFormSetFieldVisible( _formPtr "distributeV" 1)
			axlFormSetFieldVisible( _formPtr "bnDistributeV" 1)
		)
	)
	setSnapPointVisibility()
);end-defun
;---------------Form Call Back-----------------------------------------------
defun( _parmCallBack (form)
;	axlMsgPut("_parmCallBack")
	case( get(_formPtr 'curField)
		( "rbMode1" _formData~>currentMode = "align" switchForm("align") )
		( "rbMode2" _formData~>currentMode = "distribute" switchForm("distribute") )
		( "bnTop" onTop() )
		( "bnCenterH" onCenterH() )
		( "bnBottom" onBottom() )
		( "bnLeft" onLeft() )
		( "bnCenterV"  onCenterV() )
		( "bnRight" onRight() )
		( "bxGapH" 
			_formData~>useGap = _formPtr->curValue
			axlFormSetField(_formPtr "bxGapV" _formData->useGap)
			setSnapPointVisibility()
		)
		( "bxStepH"
			_formData~>useStepH = _formPtr->curValue
			if(_formData->useStepH
				then axlFormSetFieldEditable(_formPtr "fStepH" t)
				else axlFormSetFieldEditable(_formPtr "fStepH" nil)
			)
		)
		( "fStepH" _formData~>stepH = _formPtr->curValue )
		( "bnDistributeH" onDistributeH() )
		( "bxGapV" 
			_formData~>useGap = _formPtr->curValue
			axlFormSetField(_formPtr "bxGapH" _formData->useGap)
			setSnapPointVisibility()
		)
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
		( "bnOops" alignOops() )
		( "bnCancel" alignCancel() )
	);case
);end-defun

defun( setSnapPointVisibility ()
;	axlMsgPut("setSnapPointVisibility")
	if(_formData->currentMode == "align" 
		then axlFormSetFieldEditable( _formPtr "cmbSnapPoint" t)
		else
			if(_formData->useGap
				then axlFormSetFieldEditable( _formPtr "cmbSnapPoint" nil)
				else axlFormSetFieldEditable( _formPtr "cmbSnapPoint" t)
			)
	)
);end-defun

defun( initGlobalVariable ()
	_finish = nil
	if( !boundp('_formData) _formData = nil)
	_formPtr = nil
	_handler = nil
	_selectedObjects = nil
	if( !boundp('_filterOnButtons) _filterOnButtons ='(SYMBOLS VIAS TEXT))
);end-defun

