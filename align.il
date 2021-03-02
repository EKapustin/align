;
;	$Source: align.il $ $Revision: 23:fab0537ecbee $ $Branch$ $Rev: 23 $
;	$Author: Kapustin $ $Date: 2011-06-19 15:27 +0300 $
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
;	Place form files to %formpath%.
; 	Place bitmap files to %bmppath%.
;
;	skill load "o:\\Sripts\\align\\align_utils.il"
; 	skill load "o:\\Sripts\\align\\align_do.il"
;	skill load "o:\\Sripts\\align\\align.il"

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
			; remove fixed objects from selection
			_selectedObjects = checkForFixedObjects(_selectedObjects)
			; wait for object selection
			axlSelect(?groupMode nil ?prompt nil)
			if(_selectedObjects then axlMsgPut("Choose action"))
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
	else
		axlFormSetField(_formPtr "bxSnapToGrid" _formData->snapToGrid)
		axlFormSetField(_formPtr "bxGapH" _formData->useGap)
		axlFormSetField(_formPtr "bxGapV" _formData->useGap)
		axlFormSetField(_formPtr "bxStepH" _formData->useStepH)
		axlFormSetField(_formPtr "bxStepV" _formData->useStepV)
		axlFormSetField(_formPtr "fStepH" _formData->stepH)
		axlFormSetField(_formPtr "fStepV" _formData->stepV)
		axlFormSetField(_formPtr "cmbSnapPoint" _formData->snapPoint)
	)

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
		( "bxGapH"
			_formData~>useGap = _formPtr->curValue
			axlFormSetField(_formPtr "bxGapV" _formData->useGap)
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