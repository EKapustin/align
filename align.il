;
;	$Source: align.il $ $Revision: 62:89a17f0237c8 $ $Branch$ $Rev: 62 $
;	$Author: Kapustin $ $Date: 2011-09-01 01:54 +0300 $
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
;	skill load "o:/Sripts/align/align_do.il"
;	skill load "o:/Sripts/align/align_utils.il"

axlCmdRegister( "align" 'align  ?cmdType "interactive" ?doneCmd 'alignDone ?cancelCmd 'alignCancel )
axlUIMenuRegister( "move" '( ("&Align" "align") ) )

;  reload script, only for development purpose
/*axlCmdRegister( "lo" 'lo)
procedure( lo()
	load("o:/Sripts/align/align.il")
	load("o:/Sripts/align/align_do.il")
	load("o:/Sripts/align/align_utils.il")
)
*/
; @optional parameter used for call from standart Allegro command "Align components"
procedure( align( @optional components )
(prog ()
	when( axlOKToProceed()
		axlDebug(nil)
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
			if( _handler then
				if( _selectedObjects
					then
						axlDBTransactionMark(_transactionMark)
;						axlDBControl('drcEnable nil)
;						axlDBControl('dynamicFilletsOn nil)
						funcall(_handler)
						; refresh id
						axlDBRefreshId(axlGetSelSet())
						; restore selection
						_selectedObjects = refreshIDs(_selectedObjects)
						axlSingleSelectObject(_selectedObjects)
;						axlDBControl('dynamicFilletsOn t)
;						axlDBControl('drcEnable t)
						;axlDRCUpdate(t)
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
	axlDBTransactionCommit( _transactionMark )
	exitFromAlign()
);end-fun
defun( alignOops ()
	if(_handler then axlFinishEnterFun()) ;for exit from 'doPickH or 'doPickV
	axlDBTransactionOops(_transactionMark)
	; restore selection
	_selectedObjects = refreshIDs(_selectedObjects)
	axlAddSelectObject(_selectedObjects)
);end-fun
defun( alignCancel ()
	axlDBControl('drcEnable nil)
	axlDBTransactionRollback( _transactionMark )
	exitFromAlign()
);end-fun
defun( exitFromAlign ()
	_finish = t
	axlFormClose(_formPtr)
	axlDehighlightObject(_selectedObjects)
	axlCancelEnterFun()
	axlClearSelSet()
	axlUIPopupSet( nil )
	popupA = nil
	_filterOnButtons = axlGetFindFilter(t)
	_transactionMark = nil
	restoreHotKeys()
	axlDBControl('drcEnable t)
	storeFormData()
);end-defun

;-------------------Parameter form data ------------------
defun( initForm () ;
when( (axlIsDebug) axlMsgPut("initForm"))
	_formPtr = axlMiniStatusLoad( (gensym) "align.form" '_parmCallBack)
	;_formPtr = axlFormCreate( (gensym) "align.form" '(ne canvas msglines 0) '_parmCallBack t)
	when( ( _formData == nil )
		; first script launch, trying restore settings
		_formData = restoreFormData()
	)
	if( ( _formData == nil ) then
		_formData = ncons(t)

		axlFormSetField(_formPtr "bxPickH" nil)
		_formData->usePickH = nil
		axlFormSetField(_formPtr "bxStepH" nil)
		_formData->useStepH = nil
		axlFormSetField(_formPtr "bxPickV" nil)
		_formData->usePickV = nil
		axlFormSetField(_formPtr "bxStepV" nil)
		_formData->useStepV = nil
		axlFormSetField(_formPtr "fPickH" 0.0)
		_formData->pickH = 0.0
		axlFormSetField(_formPtr "fStepH" 100.0)
		_formData->stepH = 100.0
		axlFormSetField(_formPtr "fPickV" 0.0)
		_formData->pickV = 0.0
		axlFormSetField(_formPtr "fStepV" 100.0)
		_formData->stepV = 100.0
		axlFormSetField(_formPtr "bxGap" nil)
		_formData->useGap = nil
		axlFormSetField(_formPtr "bxStretch" t)
		_formData->useStretch = t
		axlFormSetField(_formPtr "bxRipup" nil)
		_formData->useRipup = nil
		axlFormSetField(_formPtr "bxSnapToGrid" t)
		_formData->snapToGrid = t
		axlFormSetField(_formPtr "cmbSnapPoint" "center")
		_formData->snapPoint = "center"
		axlFormSetField(_formPtr "sPinNumber" "1")
		_formData->snapPinNumber = "1"
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
		axlFormSetField(_formPtr "bxRipup" _formData->useRipup)
		axlFormSetField(_formPtr "bxSnapToGrid" _formData->snapToGrid)
		axlFormSetField(_formPtr "cmbSnapPoint" _formData->snapPoint)
		axlFormSetField(_formPtr "sPinNumber" _formData->snapPinNumber)
	)

	if(_formData->usePickH
		then axlFormSetFieldEditable(_formPtr "fPickH" t)
		else axlFormSetFieldEditable(_formPtr "fPickH" nil)
	)
	if(_formData->usePickV
		then axlFormSetFieldEditable(_formPtr "fPickV" t)
		else axlFormSetFieldEditable(_formPtr "fPickV" nil)
	)

	if(_formData->useStepH
		then axlFormSetFieldEditable(_formPtr "fStepH" t)
		else axlFormSetFieldEditable(_formPtr "fStepH" nil)
	)
	if(_formData->useStepV
		then axlFormSetFieldEditable(_formPtr "fStepV" t)
		else axlFormSetFieldEditable(_formPtr "fStepV" nil)
	)

	if(_formData->useStretch
	then
		axlFormSetField(_formPtr "bxRipup" nil)
		_formData->useRipup = nil
	)
	if(_formData->useRipup then
		axlFormSetField(_formPtr "bxStretch" nil)
		_formData->useStretch = nil
	)
	
	if( (_formData->snapPoint == "pin")
		then axlFormSetFieldVisible( _formPtr "sPinNumber" 1)
		else axlFormSetFieldVisible( _formPtr "sPinNumber" 0)
	)
	
;	axlFormDisplay(_formPtr)
);end-defun

;---------------Form Call Back-----------------------------------------------
defun( _parmCallBack (form)
when( (axlIsDebug) axlMsgPut("_parmCallBack"))
	case( get(_formPtr 'curField)
		( "bnTop" onTop() )
		( "bnCenterH" onCenterH() )
		( "bnBottom" onBottom() )
		( "bnLeft" onLeft() )
		( "bnCenterV"  onCenterV() )
		( "bnRight" onRight() )

		( "bxPickH" _formData->usePickH = _formPtr->curValue
			if(_formData->usePickH
				then axlFormSetFieldEditable(_formPtr "fPickH" t)
				else axlFormSetFieldEditable(_formPtr "fPickH" nil)
			)
		)
		( "fPickH" _formData->pickH = _formPtr->curValue )
		( "bnPickH" onPickH() )

		( "bxPickV" _formData->usePickV = _formPtr->curValue
			if(_formData->usePickV
				then axlFormSetFieldEditable(_formPtr "fPickV" t)
				else axlFormSetFieldEditable(_formPtr "fPickV" nil)
			)
		)
		( "fPickV" _formData->pickV = _formPtr->curValue )
		( "bnPickV" onPickV() )


		( "bxStepH"
			_formData->useStepH = _formPtr->curValue
			if(_formData->useStepH
				then axlFormSetFieldEditable(_formPtr "fStepH" t)
				else axlFormSetFieldEditable(_formPtr "fStepH" nil)
			)
		)
		( "fStepH" _formData->stepH = _formPtr->curValue )
		( "bnDistributeH" onDistributeH() )

		( "bxStepV"
			_formData->useStepV = _formPtr->curValue
			if(_formData->useStepV
				then axlFormSetFieldEditable(_formPtr "fStepV" t)
				else axlFormSetFieldEditable(_formPtr "fStepV" nil)
			)
		)
		( "fStepV" _formData->stepV = _formPtr->curValue )
		( "bnDistributeV" onDistributeV() )

		( "bxGap" _formData->useGap = _formPtr->curValue)
		( "bxStretch"
			_formData->useStretch = _formPtr->curValue
			if(_formData->useStretch
			then
				axlFormSetField(_formPtr "bxRipup" nil)
				_formData->useRipup = nil
			)
		)
		( "bxRipup"
			_formData->useRipup = _formPtr->curValue
			if(_formData->useRipup then
				axlFormSetField(_formPtr "bxStretch" nil)
				_formData->useStretch = nil
			)
		)
		( "bxSnapToGrid" _formData->snapToGrid = _formPtr->curValue	)
		( "cmbSnapPoint" 
			_formData->snapPoint = _formPtr->curValue
			if( (_formData->snapPoint == "pin")
				then axlFormSetFieldVisible( _formPtr "sPinNumber" 1)
				else axlFormSetFieldVisible( _formPtr "sPinNumber" 0)
			)
		)
		( "sPinNumber" _formData->snapPinNumber = _formPtr->curValue)
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
	let( (aliases alias aliasFunc funckeys funckey funckeyFunc)
		; find hotkey for oops command
		axlCmdRegister( "alignOops" 'alignOops ?cmdType "sub_cmd")
		aliases = axlGetAlias(nil)
		foreach( alias aliases
			aliasFunc = axlGetAlias(alias)
			case( aliasFunc
				( "oops" _oopsAlias = alias )
			)
		)
		if( boundp('_oopsAlias) && _oopsAlias
			then axlSetAlias( _oopsAlias "alignOops")
			else axlSetAlias( "F3" "alignOops")
		)
		
		; ACTIONS
		; store funckeys
		funckeys = axlGetFunckey(nil)
		_alnOriginalFunckeys = nil
		foreach( funckey funckeys
			funckeyFunc = axlGetFunckey(funckey)
			_alnOriginalFunckeys = cons(list(funckey funckeyFunc) _alnOriginalFunckeys)
		)
		axlCmdRegister( "alnTop" 'onTop ?cmdType "sub_cmd")
		axlCmdRegister( "alnBottom" 'onBottom ?cmdType "sub_cmd")
		axlCmdRegister( "alnLeft" 'onLeft ?cmdType "sub_cmd")
		axlCmdRegister( "alnRight" 'onRight ?cmdType "sub_cmd")
		axlCmdRegister( "alnCenterH" 'onCenterH ?cmdType "sub_cmd")
		axlCmdRegister( "alnCenterV" 'onCenterV ?cmdType "sub_cmd")
		axlCmdRegister( "alnDistributeH" 'onDistributeH ?cmdType "sub_cmd")
		axlCmdRegister( "alnDistributeV" 'onDistributeV ?cmdType "sub_cmd")
		axlCmdRegister( "alnPickH" 'onPickH ?cmdType "sub_cmd")
		axlCmdRegister( "alnPickV" 'onPickV ?cmdType "sub_cmd")
		axlSetFunckey( "a" "alnLeft")
		axlSetFunckey( "s" "alnBottom")
		axlSetFunckey( "w" "alnTop")
		axlSetFunckey( "d" "alnRight")
		axlSetFunckey( "q" "alnCenterH")
		axlSetFunckey( "z" "alnCenterV")
		axlSetFunckey( "e" "alnDistributeH")
		axlSetFunckey( "c" "alnDistributeV")
		axlSetFunckey( "r" "alnPickH")
		axlSetFunckey( "v" "alnPickV")
	) ; let
);end-defun

defun( restoreHotKeys ()
	let( (funckey)
		
		when(boundp('_oopsAlias) && _oopsAlias
			axlSetAlias( _oopsAlias "oops")
			_oopsAlias = nil
		)
		; restore funckeys
		foreach( funckey _alnOriginalFunckeys
			when( !axlIsProtectAlias(car(funckey)) ; skip readonly
				axlSetFunckey(car(funckey) cadr(funckey))
			)
		)
		_alnOriginalFunckeys = nil
		axlCmdUnregister("alignOops")
		axlCmdUnregister("alnLeft")
		axlCmdUnregister("alnBottom")
		axlCmdUnregister("alnTop")
		axlCmdUnregister("alnRight")
		axlCmdUnregister("alnCenterH")
		axlCmdUnregister("alnCenterV")
		axlCmdUnregister("alnDistributeH")
		axlCmdUnregister("alnDistributeV")
		axlCmdUnregister("alnPickH")
		axlCmdUnregister("alnPickV")
		axlSetAlias( "a" nil)
		axlSetAlias( "s" nil)
		axlSetAlias( "w" nil)
		axlSetAlias( "d" nil)
		axlSetAlias( "q" nil)
		axlSetAlias( "z" nil)
		axlSetAlias( "e" nil)
		axlSetAlias( "c" nil)
		axlSetAlias( "r" nil)
		axlSetAlias( "v" nil)
	) ; let
);end-defun

;
; Store form settings to attachment.
; 
defun( storeFormData ()
	let( (sFormData attachment )
		sFormData = sprintf(nil "%L" _formData)
		attachment = axlGetAttachment("AlignFormData" 'string)
		if( attachment
		then
			attachment->data = sFormData
			axlSetAttachment(attachment "QWE123qwe")
		else
			attachment = axlCreateAttachment("AlignFormData" "QWE123qwe" 0 'string sFormData)
		);if
	) ; let
);end-defun

;
; Restore form settings from attachment.
;
defun( restoreFormData ()
	prog( (formData attachment sFormData )
		formData = nil
		attachment = axlGetAttachment("AlignFormData" 'string)
		sFormData = attachment->data
		when( sFormData
			formData = car(errsetstring(strcat("'" sFormData)))
		)
		return(formData)
	) ; let
);end-defun

