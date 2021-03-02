;
;	$Source: align.il $ $Revision: 31:8636e158e117 $ $Branch$ $Rev: 31 $
;	$Author: Kapustin $ $Date: 2011-06-28 01:15 +0300 $
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
;					pickH.bmp
;					pickV.bmp
;	Place form files to %formpath%.
; 	Place bitmap files to %bmppath%.
;
;	skill load "o:/Sripts/align/align.il"
; 	skill load "o:/Sripts/align/align_do.il"
;	skill load "o:/Sripts/align/align_utils.il"



axlCmdRegister( "align" 'align  ?cmdType "interactive" ?doneCmd 'alignDone ?cancelCmd 'alignCancel )
axlUIMenuRegister( "move" '( ("&Align" "align") ) )

procedure( align( )
(prog ()
	when( axlOKToProceed()
		axlClearSelSet()
		initGlobalVariable()
		initForm()
		initHotKeys()

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
			; get objects from previous iteration
			_selectedObjects = axlGetSelSet()
			if(_selectedObjects then axlMsgPut("Choose action"))
			; remove fixed objects from selection
			_selectedObjects = checkForFixedObjects(_selectedObjects)

			; wait for object selection
			axlSelect(?groupMode nil ?prompt nil)
			; execute operation chosen in form
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
		axlSetAlias( _oopsAlias "oops")
		_oopsAlias = nil
		axlCmdUnregister("alignOops")
	)
);end-fun
defun( alignOops ()
	if(_handler then axlFinishEnterFun()) ;for exit from 'doPickH or 'doPickV
	axlDBTransactionOops(_transactionMark)
	; restore selection
	_selectedObjects = refreshIDs(_selectedObjects)
	axlAddSelectObject(_selectedObjects)
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
		axlSetAlias( _oopsAlias "oops")
		_oopsAlias = nil
		axlCmdUnregister("alignOops")
	)
);end-fun

;-------------------Parameter form data ------------------
defun( initForm () ;
;	axlMsgPut("initForm")
	_formPtr = axlMiniStatusLoad( (gensym) "align.form" '_parmCallBack)
	;_formPtr = axlFormCreate( (gensym) "align.form" '(ne canvas msglines 0) '_parmCallBack t)
	if( ( _formData == nil ) then
		_formData = t

		axlFormSetField(_formPtr "bxPickH" nil)
		_formData~>usePickH = nil
		axlFormSetField(_formPtr "bxStepH" nil)
		_formData~>useStepH = nil
		axlFormSetField(_formPtr "bxPickV" nil)
		_formData~>usePickV = nil
		axlFormSetField(_formPtr "bxStepV" nil)
		_formData~>useStepV = nil

		axlFormSetField(_formPtr "fPickH" 0.0)
		_formData~>pickH = 0.0
		axlFormSetField(_formPtr "fStepH" 100.0)
		_formData~>stepH = 100.0
		axlFormSetField(_formPtr "fPickV" 0.0)
		_formData~>pickV = 0.0
		axlFormSetField(_formPtr "fStepV" 100.0)
		_formData~>stepV = 100.0
		axlFormSetField(_formPtr "bxGap" t)
		_formData~>useGap = t
		axlFormSetField(_formPtr "bxStretch" t)
		_formData~>useStretch = t
		axlFormSetField(_formPtr "bxSnapToGrid" t)
		_formData~>snapToGrid = t
		axlFormSetField(_formPtr "cmbSnapPoint" "center")
		_formData~>snapPoint = "center"
	else
		axlFormSetField(_formPtr "bxPickH" _formData->usePickH)
		axlFormSetField(_formPtr "bxStepH" _formData->useStepH)
		axlFormSetField(_formPtr "bxPickV" _formData->usePickV)
		axlFormSetField(_formPtr "bxStepV" _formData->useStepV)
		axlFormSetField(_formPtr "fPickH" _formData->pickH)
		axlFormSetField(_formPtr "fStepH" _formData->stepH)
		axlFormSetField(_formPtr "fPickV" _formData->pickV)
		axlFormSetField(_formPtr "fStepV" _formData->stepV)
		axlFormSetField(_formPtr "bxGap" _formData->useGap)
		axlFormSetField(_formPtr "bxStretch" _formData->useStretch)
		axlFormSetField(_formPtr "bxSnapToGrid" _formData->snapToGrid)
		axlFormSetField(_formPtr "cmbSnapPoint" _formData->snapPoint)
	)

	if(_formData->usePickH
		then axlFormSetFieldEditable(_formPtr "fPickH" t)
		else axlFormSetFieldEditable(_formPtr "fPickH" nil)
	)
	if(_formData->usePickV
		then axlFormSetFieldEditable(_formPtr "fPickV" t)
		else axlFormSetFieldEditable(_formPtr "fPickV" nil)
	)
; temporary disabled features
	axlFormSetFieldEditable(_formPtr "bxStretch" nil)
; temporary disabled features

	if(_formData->useStepH
		then axlFormSetFieldEditable(_formPtr "fStepH" t)
		else axlFormSetFieldEditable(_formPtr "fStepH" nil)
	)
	if(_formData->useStepV
		then axlFormSetFieldEditable(_formPtr "fStepV" t)
		else axlFormSetFieldEditable(_formPtr "fStepV" nil)
	)
;	axlFormDisplay(_formPtr)
);end-defun

;---------------Form Call Back-----------------------------------------------
defun( _parmCallBack (form)
;	axlMsgPut("_parmCallBack")
	case( get(_formPtr 'curField)
		( "bnTop" onTop() )
		( "bnCenterH" onCenterH() )
		( "bnBottom" onBottom() )
		( "bnLeft" onLeft() )
		( "bnCenterV"  onCenterV() )
		( "bnRight" onRight() )

		( "bxPickH" _formData~>usePickH = _formPtr->curValue
			if(_formData->usePickH
				then axlFormSetFieldEditable(_formPtr "fPickH" t)
				else axlFormSetFieldEditable(_formPtr "fPickH" nil)
			)
		)
		( "fPickH" _formData~>pickH = _formPtr->curValue )
		( "bnPickH" onPickH() )

		( "bxPickV" _formData~>usePickV = _formPtr->curValue
			if(_formData->usePickV
				then axlFormSetFieldEditable(_formPtr "fPickV" t)
				else axlFormSetFieldEditable(_formPtr "fPickV" nil)
			)
		)
		( "fPickV" _formData~>pickV = _formPtr->curValue )
		( "bnPickV" onPickV() )


		( "bxStepH"
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

		( "bxGap" _formData~>useGap = _formPtr->curValue)
		( "bxStretch" _formData~>useStretch = _formPtr->curValue)
		( "bxSnapToGrid" _formData~>snapToGrid = _formPtr->curValue	)
		( "cmbSnapPoint" _formData~>snapPoint = _formPtr->curValue )
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

defun( initHotKeys ()
	let( (aliases alias aliasFun)
		axlCmdRegister( "alignOops" 'alignOops ?cmdType "sub_cmd")
		aliases = axlGetAlias(nil)
		foreach( alias aliases
			aliasFun = axlGetAlias(alias)
			if( aliasFun == "oops" _oopsAlias = alias )
		)
		if(_oopsAlias
			then axlSetAlias( _oopsAlias "alignOops")
			else axlSetAlias( "F3" "alignOops")
		)
	) ; let
);end-defun