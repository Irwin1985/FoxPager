* ========================================================== *
* FoxPager class
* Date: 2022-01-19 17:56
* Version: 0.1
* Author: Irwin Rodríguez <rodriguez.irwin@gmail.com>
* ========================================================== *
define class foxPager as session
	#define DEFAULT_ROWS 5
	hidden nPageRange
	hidden cCursorName
	hidden nDataSessionID
	hidden nTotalPages
	hidden nCurrentPage
	hidden nMinRow
	hidden nMaxRow
	hidden oEventHandler
	hidden cDelegateEvent
	hidden cResultName
	cLastErrorText = ''
	sendDelegateParams = .f.

	function init(tcCursorName, tnPageRange, tnSessionID)
		with this
			.cCursorName = iif(type('tcCursorName') = 'L', '', tcCursorName)
			.nPageRange = iif(type('tnPageRange') = 'L', DEFAULT_ROWS, tnPageRange)
			.nDataSessionID = iif(type('tnSessionID') = 'L', set("Datasession"), tnSessionID)
			.nTotalPages = 0
			.nCurrentPage = 0
			.nMinRow = 0
			.nMaxRow = 0
			.oEventHandler = .null.
			.cDelegateEvent = ''
			.cResultName = 'cResult'
		endwith
	endfunc

	function setPageRange(tnPageRange)
		this.nPageRange = tnPageRange
	endfunc

	function setCursorName(tcCursorName)
		this.cCursorName = tcCursorName
		if !empty(this.cCursorName)
			this.nTotalPages = ceiling(reccount(this.cCursorName) / this.nPageRange)
			if this.nTotalPages <= 0
				this.nTotalPages = 1
			endif
			this.nCurrentPage = 1
		endif
	endfunc

	function setDataSessionID(tnSessionID)
		if empty(tnSessionID)
			tnSessionID = set("Datasession")
		endif
		this.nDataSessionID = tnSessionID
		set datasession to (this.nDataSessionID)
	endfunc

	function setEventHandler(toEventHandler)
		this.oEventHandler = toEventHandler
	endfunc

	function setDelegateEvent(tcDelegateEvent)
		this.cDelegateEvent = tcDelegateEvent
	endfunc
	
	function setResultName(tcResultName)
		this.cResultName = tcResultName
	endfunc

	function run
		if empty(this.cDelegateEvent)
			wait "before running you must provide a delegate event." window nowait
		endif
		do while this.hasNext()
			this.next()
		enddo
	endfunc

	function hasNext
		return this.nCurrentPage <= this.nTotalPages
	endfunc

	function next(toEventHandler, tcDelegateEvent, tlSendParams)
		if empty(tcDelegateEvent)
			if empty(this.cDelegateEvent)
				wait "Ivalid delegate event name." window nowait
			endif
			tcDelegateEvent = this.cDelegateEvent
		endif
		if pcount() <= 2
			tlSendParams = this.sendDelegateParams
		endif
		try
			local loEx as exception, loCaller as object, lcCommand as string
			this.updateRowProperties()
			select * from (this.cCursorName) where between(recno(), this.nMinRow, this.nMaxRow) into cursor (this.cResultName)
			loCaller = iif(type('toEventHandler') = 'O', toEventHandler, iif(!isnull(this.oEventHandler), this.oEventHandler, .null.))
			if isnull(loCaller)
				wait "Invalid handler." window nowait
				return
			endif
			lcCommand = tcDelegateEvent
			if type('loCaller') = 'O'
				lcCommand = "loCaller." + lcCommand
			endif
			lcCommand = lcCommand + "("
			if tlSendParams
				lcCommand = lcCommand + "this.nMinRow, this.nMaxRow"
			endif
			lcCommand = lcCommand + ")"
			&lcCommand
			this.nCurrentPage = this.nCurrentPage + 1
		catch to loEx
			this.cLastErrorText = "ERROR NRO: " + alltrim(str(loEx.errorno))
			this.cLastErrorText = this.cLastErrorText + chr(13) + "LINE: "  	+ alltrim(str(loEx.lineno))
			this.cLastErrorText = this.cLastErrorText + chr(13) + "MESSAGE: "  	+ alltrim(loEx.message)
			this.cLastErrorText = this.cLastErrorText + chr(13) + "PROGRAM: "  	+ alltrim(loEx.procedure)
			wait this.cLastErrorText window nowait
		finally
			use in (this.cResultName)
			store .null. to loEx
			release loEx
		endtry
	endfunc

	hidden function updateRowProperties
		if empty(this.cCursorName)
			wait "Invalid cursor name." window nowait
		endif
		this.nMinRow = (this.nCurrentPage-1) * this.nPageRange + iif(this.nCurrentPage > 1, 1, 0)
		this.nMaxRow = iif(this.nCurrentPage < this.nTotalPages, this.nCurrentPage * this.nPageRange, reccount(this.cCursorName))
	endfunc
enddefine
