// edKith 07.01.2016
// added language switch support for Russian Localization
class OptionWnd extends UICommonAPI;


const PARTY_MODIFY_REQUEST = 0;
const OPTION_CHANGE = 1;


//ĳ���� ǥ������ �����̴� �׼�
const RENDERCHARACTERLIMIT_MIN = 10;
const RENDERCHARACTERLIMIT_MAX = 400;

var bool bPartyMember;
var bool bPartyMaster;
//var bool bPartyRoomMaster;
//var int Lootingtype;
var bool NowLooting; //��Ƽ���õ��߿��� �����޺��ڽ��� �������� �Ѵ�

var int g_CurrentMaxWidth;
var int g_CurrentMaxHeight;
var int nPixelShaderVersion;
var int nVertexShaderVersion;
var float gSoundVolume;
var float gMusicVolume;
var float gWavVoiceVolume;
var float gOggVoiceVolume;
var Array<ResolutionInfo> ResolutionList;
var Array<int> RefreshRateList;
var bool bShow;

var bool m_bL2Shader;
var bool m_bDepthBufferShadow;
var bool m_bDOF;
var bool m_bShaderWater;
//var bool m_bPartyRejected;

// ��� �ϸ� �ǵ����� ���ؼ� ���� ���� ����ϰ� ���� ���� - lancelot 2006. 6. 13.
var int m_iPrevSoundTick;
var int m_iPrevMusicTick;
var int m_iPrevSystemTick;
var int m_iPrevTutorialTick;
var bool bg_Temp;

// ��Ƽ��Ī�濡 ������ �����ΰ�?	2006.10.19 ttmayrin
var bool m_bPartyMatchRoomState;

//solasys-�����׽�Ʈ����
var bool m_bAirState;

var WindowHandle TargetStatusWnd;
var WindowHandle StatusWnd;
var WindowHandle SystemMenuWnd;
var WindowHandle Me;

var EditBoxHandle KeySettingInput;
var ButtonHandle Btn_SaveCurrentKey;
var ButtonHandle Btn_CancelCurrentKey;
var ButtonHandle Btn_AboutPatch;
var ButtonHandle Btn_ChatOff;

var CheckBoxHandle buffsizeCheck;
var CheckBoxHandle autoRecCheck;
var CheckBoxHandle funNickname;
var CheckBoxHandle dmgOn;
//var EditBoxHandle funNicknameEdit;

var StatusIconHandle s_handle;

var DialogBox	dScript;

var AbnormalStatusWnd script_abnormal;
var OlympiadDmgWnd script_oly;
var PlayerOlyStat script_olystat;
var OnScreenDmg script_osdmg;

function ResetRefreshRate( optional int a_nWidth, optional int a_nHeight )
{
	local int i;

	GetRefreshRateList( RefreshRateList, a_nWidth, a_nHeight );
	//debug( "RefreshRateList.Length " $ RefreshRateList.Length );
	class'UIAPI_COMBOBOX'.static.Clear( "OptionWnd.RefreshRateBox" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		//~ debug( "RefreshRateList[ i ] " $ RefreshRateList[ i ] );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.RefreshRateBox", RefreshRateList[ i ] $ "Hz" );
	}
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.RefreshRateBox", 0 );
}
function OnRegisterEvent()
{

	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );//��Ƽ���ÿɼ� ���������� ���̾�α׿� ������ �ʿ䰡 �ִ�.

	RegisterEvent( EV_AskPartyLootingModify ); //��Ƽ������ ���� ���� ���θ� ����� 
	RegisterEvent( EV_PartyLootingHasModified); //��Ƽ������ ����� �˷���
		// S: actor char name
		// d: nItemRoutingType

	//solasys-�����׽�Ʈ
	RegisterEvent( EV_AirStateOn );
	RegisterEvent( EV_AirStateOff );
	
	RegisterEvent( EV_MinFrameRateChanged );
	RegisterEvent( EV_PartyMemberChanged );
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	RegisterEvent( EV_PartyHasDismissed );//��Ƽ�� ��ü�Ǿ���
	RegisterEvent( EV_OustPartyMember ); //��Ƽ���� �߹������
	RegisterEvent( EV_BecamePartyMember ); //��Ƽ�� ����� ��
	RegisterEvent( EV_BecamePartyMaster ); //��Ƽ���̵�
	RegisterEvent( EV_HandOverPartyMaster ); //��Ƽ���� �絵��
	RegisterEvent( EV_RecvPartyMaster ); //��Ƽ���� �絵����
// 	RegisterEvent( EV_PartyMatchRoomStart ); //��Ƽ�����̵�
 	RegisterEvent( EV_PartyMatchRoomClose ); //��Ƽ�����
	RegisterEvent( EV_WithdrawParty ); //��Ƽ���� Ż����
	

}


function InitHandle()
{
	TargetStatusWnd = GetHandle( "TargetStatusWnd" );
	StatusWnd = GetHandle( "StatusWnd" );
	SystemMenuWnd = GetHandle( "SystemMenuWnd" );

	KeySettingInput = EditBoxHandle ( GetHandle( "OptionWnd.KeySettingInput" ) );
	Btn_SaveCurrentKey = ButtonHandle ( GetHandle( "OptionWnd.Btn_SaveCurrentKey" ) );
	Btn_CancelCurrentKey = ButtonHandle ( GetHandle( "OptionWnd.Btn_CancelCurrentKey" ) );
	Btn_AboutPatch = ButtonHandle ( GetHandle( "OptionWnd.btnForumLink" ) );
	Btn_ChatOff = ButtonHandle ( GetHandle( "OptionWnd.btnChatOff" ) );
	buffsizeCheck = CheckBoxHandle ( GetHandle( "OptionWnd.largeBuff" ) );
	autoRecCheck = CheckBoxHandle ( GetHandle( "OptionWnd.autoRec" ) );
	funNickname = CheckBoxHandle ( GetHandle( "OptionWnd.funNickname" ) );
	dmgOn = CheckBoxHandle ( GetHandle( "OptionWnd.dmgOn" ) );
	//funNicknameEdit = EditBoxHandle ( GetHandle( "OptionWnd.funNicknameEdit" ) );
}

function InitHandleCOD()
{
	TargetStatusWnd = GetWindowHandle( "TargetStatusWnd" );
	StatusWnd = GetWindowHandle( "StatusWnd" );
	SystemMenuWnd = GetWindowHandle( "SystemMenuWnd" );
	Me = GetWindowHandle( "OptionWnd" );

	KeySettingInput = GetEditBoxHandle( "OptionWnd.KeySettingInput" );
	Btn_SaveCurrentKey = GetButtonHandle ( "OptionWnd.Btn_SaveCurrentKey" );
	Btn_CancelCurrentKey = GetButtonHandle ( "OptionWnd.Btn_CancelCurrentKey" );
	Btn_AboutPatch = GetButtonHandle ( "OptionWnd.btnForumLink" );
	Btn_ChatOff = GetButtonHandle ( "OptionWnd.btnChatOff" );
	buffsizeCheck = GetCheckBoxHandle ("OptionWnd.largeBuff");
	autoRecCheck = GetCheckBoxHandle ("OptionWnd.autoRec");
	funNickname = GetCheckBoxHandle ("OptionWnd.funNickname");
	dmgOn = GetCheckBoxHandle ("OptionWnd.dmgOn");
	//funNicknameEdit = GetEditBoxHandle ("OptionWnd.funNicknameEdit");
}

function OnLoad()
{
	local int i;
	local int nMultiSample;
	local bool bEnableEngSelection;
	local ELanguageType Language;
	local string strResolution;
	
	s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon");
	
	dScript = DialogBox(GetScript("DialogBox"));
	script_abnormal = AbnormalStatusWnd( GetScript( "AbnormalStatusWnd" ) );
	script_oly = OlympiadDmgWnd( GetScript( "OlympiadDmgWnd" ) );
	script_olystat = PlayerOlyStat(GetScript("PlayerOlyStat"));
	script_osdmg = OnScreenDmg(GetScript("OnScreenDmg"));

	bPartyMember = false;
	bPartyMaster = false;
//	bPartyRoomMaster = false;
//	Lootingtype = 0;
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		InitHandle();
	else
		InitHandleCOD();
	
	m_bAirState = false;

	// 2006/03/26 - added register state by NeverDie. multi-registering states can only be placed in uc...
	RegisterState( "OptionWnd", "GamingState" );
	RegisterState( "OptionWnd", "LoginState" );

	// Shader version
	GetShaderVersion( nPixelShaderVersion, nVertexShaderVersion );

	GetResolutionList( ResolutionList );
	
	SetOptionBool( "Game", "HideDropItem", false );
	
	if (GetOptionInt("Buff Control", "Size") == 32)
		buffsizeCheck.SetCheck(true);
	else
		buffsizeCheck.SetCheck(false);
	autoRecCheck.SetCheck(GetOptionBool("Replay Control", "Mode"));
	funNickname.SetCheck(GetOptionBool("Status Control", "Mode"));
	dmgOn.SetCheck(GetOptionBool("Damage Control", "Mode"));
	script_oly.optCheck = GetOptionBool("Replay Control", "Mode");
	script_oly.isFunNick = GetOptionBool("Status Control", "Mode");
	
	for( i = 0; i < ResolutionList.Length; ++i )
	{
		strResolution = "" $ ResolutionList[ i ].nWidth $ "*" $ ResolutionList[ i ].nHeight $ " " $ ResolutionList[ i ].nColorBit $ "bit";
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.ResBox", strResolution );
	}

	ResetRefreshRate();


	nMultiSample = GetMultiSample();
	if( 0 == nMultiSample )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 869 );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.AABox" );
	}
	else if( 1 == nMultiSample )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 869 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 870 );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AABox" );
	}
	else if( 2 == nMultiSample )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 869 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 870 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 871 );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AABox" );
	}

	bEnableEngSelection = IsEnableEngSelection();
	Language = GetLanguage();
	switch( Language )
	{
	case LANG_None:
		break;
	case LANG_Korean:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Korean" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_English:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		break;
	case LANG_Japanese:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Japanese" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Taiwan:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Chinese(Taiwan)" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Chinese:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "China" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Thai:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Thai" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Philippine:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		break;
	//edKith
	//07.01.2016
	//Added Russian Language Support
	case LANG_Russia:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Russian" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	default:
		break;
	}

	if( CanUseHDR() )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.HDRBox", 1230 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.HDRBox", 1231 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.HDRBox", 1232 );
	}
	

	// 2007/11/16 Now new functions(LoadVideoOption,LoadAudioOption,LoadGameOption) load the ini configuration. - NeverDie
	//InitVideoOption();
	//InitAudioOption();
	//InitGameOption();
	LoadVideoOption();
	LoadAudioOption();
	LoadGameOption();
}

function RefreshLootingBox()
{
	local PartyWnd script;
	// debug("Refresh looting box");
	if(NowLooting)
	{
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
		return;
	}
	if( GetPartyMemberCount() > 0 || m_bPartyMatchRoomState )
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
	else
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );

	script = PartyWnd(GetScript("PartyWnd"));
	if(script.AmILeader())
	{		
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );
	}
}


function int GetPawnValue( out int iCurrTick, int iNumTick, int MIN, int MAX )
{
	local int iValue;

	if(iCurrTick<0 || iCurrTick>=(iNumTick-1))
	{
		iValue = 10000;
		iCurrTick = (iNumTick-1);
	}
	else
	{
		iValue = 10+iCurrTick*(MAX-MIN)/(iNumTick-2)-(Sin( Pi*iCurrTick/(iNumTick-2) ) * MAX/3.66);
	}
	
	return iValue;
}

function InitVideoOption()
{
	local int i;
	local int nResolutionIndex;
	local float fGamma;
	//local float fPawnClippingRange;
	//local float fTerrainClippingRange;
	local bool bRenderDeco;
	local int nPostProcessType;
	local bool bShadow;
	local int nTextureDetail;
	local int nModelDetail;
	local int nSkipAnim;
	local bool bWaterEffect;
	local int nWaterEffectType;
	local int nMultiSample;
	local int nOption;
	local bool bOption;
	local bool bL2Shader;
	local bool bDOF;
	local bool bShaderWater;
	local int iPawnValue;
	local int iNumTick;
	local int RenderActorLimitOpt;

	// �ػ� - ResBox
	nResolutionIndex = GetResolutionIndex();
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ResBox", nResolutionIndex );

	// �ֻ��� - RefreshRateBox
	GetRefreshRateList( RefreshRateList );
	class'UIAPI_COMBOBOX'.static.Clear( "OptionWnd.RefreshRateBox" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.RefreshRateBox", RefreshRateList[ i ] $ "Hz" );
	}
	nOption = GetOptionInt( "Video", "RefreshRate" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		//~ debug( "RefreshRateList[ " $ i $ " ] = " $ RefreshRateList[ i ] );
		if( RefreshRateList[ i ] == nOption )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.RefreshRateBox", i );
	}

	// ������ - GammaBox
	fGamma = GetOptionFloat( "Video", "Gamma" );
	if( 1.2f <= fGamma )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 0 );
	else if( 1.0f <= fGamma && fGamma < 1.2f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 1 );
	else if( 0.8f <= fGamma && fGamma < 1.0f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 2 );
	else if( 0.6f <= fGamma && fGamma < 0.8f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 3 );
	else if( fGamma < 0.6f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 4 );

	// �þ�-ĳ���� - CharBox
	nOption = GetOptionInt( "Video", "PawnClippingRange" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.CharBox", nOption );

	// �þ�-���� - TerrainBox
	nOption = GetOptionInt( "Video", "TerrainClippingRange" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.TerrainBox", nOption );

	// ���ȿ�� - DecoBox
	bRenderDeco = GetOptionBool( "Video", "RenderDeco" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.DecoBox", bRenderDeco );

	// ȭ���������̴� - HDRBox
	nPostProcessType = GetOptionInt( "Video", "PostProc" );
	
	//~ debug ("����Ʈ ���μ���Ÿ��" @ nPostProcessType);
	if( 0 <= nPostProcessType && nPostProcessType <= 5 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", nPostProcessType );
	else
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", 0 );

	// �׸��� - ShadowBox
	bShadow = GetOptionBool( "Video", "PawnShadow" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ShadowBox", bShadow );

	// �ؽ��ĵ����� - TextureBox
	nTextureDetail = GetOptionInt( "Video", "TextureDetail" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.TextureBox", Max( 0, Min( 2, nTextureDetail ) ) );

	// �𵨸������� - ModelBox
	nModelDetail = GetOptionInt( "Video", "ModelDetail" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ModelBox", nModelDetail );

	// ��ǵ����� - AnimBox
	nSkipAnim = GetOptionInt( "Video", "SkipAnim" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.AnimBox", nSkipAnim );

	// �ݻ�ȿ�� - ReflectBox
	if( nPixelShaderVersion < 12 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}
	else
	{
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );

		bWaterEffect = GetOptionBool( "L2WaterEffect", "IsUseEffect" );
		nWaterEffectType = GetOptionInt( "L2WaterEffect", "EffectType" );
		if( !bWaterEffect )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
		else if( nWaterEffectType == 1 )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 1 );
		else if ( nWaterEffectType == 2 )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 2 );
		else
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}

	// �ؽ������͸� - TriBox
	bOption = GetOptionBool( "Video", "UseTrilinear" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.TriBox", bOption );

	// ĳ����ǥ������ - RenderCharacterCount
	RenderActorLimitOpt = GetOptionInt( "Video", "RenderActorLimitOpt" );
	iNumTick = class'UIAPI_SLIDERCTRL'.static.GetTotalTickCount("OptionWnd.CharacterLimitSliderCtrl");

	iPawnValue = GetPawnValue( RenderActorLimitOpt, iNumTick, RENDERCHARACTERLIMIT_MIN, RENDERCHARACTERLIMIT_MAX );

	class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.CharacterLimitSliderCtrl", RenderActorLimitOpt);
	SetOptionInt( "Video", "RENDERCHARACTERCOUNT", iPawnValue );

	// ��Ƽ�˸��ƽ�	- AABox
	nMultiSample = GetMultiSample();
	if( nMultiSample > 0 && !( 3 <= nPostProcessType && nPostProcessType <= 5 ) ) 
	{
		nOption = GetOptionInt( "Video", "AntiAliasing" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.AABox", nOption );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AABox" );
	}
	else 
	{
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.AABox", 0 );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.AABox" );
	}
	
	//���̴� 3.0
	bL2Shader = GetOptionBool( "Video", "L2Shader" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30Box", bL2Shader );
	if ( nPixelShaderVersion >= 30 && nVertexShaderVersion >= 30)
	{
		if(bL2Shader)
		{
			//class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.GPUAnimationCheckBox" );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30DOFBOX" );
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30WaterEffectBox" );
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30ShadowBox" );
		}
		else
		{
			//class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.GPUAnimationCheckBox" );
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
		}
		//���̴� 3.0 - DOF?
		bDOF = GetOptionBool( "Video", "S30DOFBOX" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", bDOF );
			
		//���̴� 3.0 - ��ȿ��
		bShaderWater = GetOptionBool( "Video", "S30WaterEffectBox" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", bShaderWater );
		
		//���̴� 3.0 - �׸���.
		m_bDepthBufferShadow = GetOptionBool( "Video", "S30ShadowBox" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", m_bDepthBufferShadow );
	}
	else
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30Box" );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
	}
	
	// �ּ����������� - FrameBox
	bOption = GetOptionBool( "Video", "IsKeepMinFrameRate" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.FrameBox", bOption );
	if( bOption ) 
		MinFrameRateOn();
	else
		MinFrameRateOff();

	// ��ũ���� ǰ�� - CaptureBox
	nOption = GetOptionInt( "Game", "ScreenShotQuality" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.CaptureBox", nOption );
		
	nOption = GetOptionInt("Game", "LayoutDF");
	//~ Debug ("�⺻ ���̾ƿ� ��ȣ:" @ nOption);
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.DefaultPositionBox", nOption );
	
	if (nOption ==1)
	{
		SetStuck(true);
	}
	else
	{
		SetStuck(false);
	}
	
	
	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie

	// ���ȿ�� - WeatherEffectComboBox
	nOption = GetOptionInt( "Video", "WeatherEffect" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.WeatherEffectComboBox", nOption );

	// GPU�ִϸ��̼� - GPUAnimationCheckBox
	bOption = GetOptionBool( "Video", "GPUAnimation" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", bOption );
	if( nVertexShaderVersion < 20 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.GPUAnimationCheckBox" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", false );
	}
}

function InitAudioOption()
{
	local float fSoundVolume;
	local float fMusicVolume;
	local float fWavVoiceVolume;
	local float fOggVoiceVolume;

	// lancelot 2006. 6. 13.
	local int iSoundVolume;
	local int iMusicVolume;
	local int iSystemVolume;
	local int iTutorialVolume;

	if (GetOptionBool( "Audio", "AudioMuteOn" ) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.mutecheckbox", true);

	}
	else
	{
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.mutecheckbox", false);
	}
		

	if( CanUseAudio() )
	{
		// ȿ�������� - EffectVolumeSliderCtrl
		fSoundVolume = GetOptionFloat( "Audio", "SoundVolume" );
		gSoundVolume = fSoundVolume;

		if( 0.0f <= fSoundVolume && fSoundVolume < 0.2f )
			iSoundVolume=0;//Merc moded there, default: 0, mine: 1
		else if( 0.2f <= fSoundVolume && fSoundVolume < 0.4f )
			iSoundVolume=1;
		else if( 0.4f <= fSoundVolume && fSoundVolume < 0.6f )
			iSoundVolume=2;
		else if( 0.6f <= fSoundVolume && fSoundVolume < 0.8f )
			iSoundVolume=3;
		else if( 0.8f <= fSoundVolume && fSoundVolume < 1.0f )
			iSoundVolume=4;
		else if( 1.0f <= fSoundVolume )
			iSoundVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.EffectVolumeSliderCtrl", iSoundVolume);


		// ���Ǻ���	- MusicVolumeSliderCtrl
		fMusicVolume = GetOptionFloat( "Audio", "MusicVolume" );
		gMusicVolume=fMusicVolume;

		if( 0.0f <= fMusicVolume && fMusicVolume < 0.2f )
			iMusicVolume=0;//Merc moded there, default: 0, mine: 2
		else if( 0.2f <= fMusicVolume && fMusicVolume < 0.4f )
			iMusicVolume=1;
		else if( 0.4f <= fMusicVolume && fMusicVolume < 0.6f )
			iMusicVolume=2;
		else if( 0.6f <= fMusicVolume && fMusicVolume < 0.8f )
			iMusicVolume=3;
		else if( 0.8f <= fMusicVolume && fMusicVolume < 1.0f )
			iMusicVolume=4;
		else if( 1.0f <= fMusicVolume )
			iMusicVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.MusicVolumeSliderCtrl", iMusicVolume);

		// �ý������� - SystemVolumeSliderCtrl
		fWavVoiceVolume = GetOptionFloat( "Audio", "WavVoiceVolume" );
		gWavVoiceVolume = fWavVoiceVolume;

		if( 0.0f <= fWavVoiceVolume && fWavVoiceVolume < 0.2f )
			iSystemVolume=0;
		else if( 0.2f <= fWavVoiceVolume && fWavVoiceVolume < 0.4f )
			iSystemVolume=1;
		else if( 0.4f <= fWavVoiceVolume && fWavVoiceVolume < 0.6f )
			iSystemVolume=2;
		else if( 0.6f <= fWavVoiceVolume && fWavVoiceVolume < 0.8f )
			iSystemVolume=3;
		else if( 0.8f <= fWavVoiceVolume && fWavVoiceVolume < 1.0f )
			iSystemVolume=4;
		else if( 1.0f <= fWavVoiceVolume )
			iSystemVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.SystemVolumeSliderCtrl", iSystemVolume);


		// Ʃ�丮������	- TutorialBox
		fOggVoiceVolume = GetOptionFloat( "Audio", "OggVoiceVolume" );
		gOggVoiceVolume = fOggVoiceVolume;
			
		if( 0.0f <= fOggVoiceVolume && fOggVoiceVolume < 0.2f )
			iTutorialVolume=0;
		else if( 0.2f <= fOggVoiceVolume && fOggVoiceVolume < 0.4f )
			iTutorialVolume=1;
		else if( 0.4f <= fOggVoiceVolume && fOggVoiceVolume < 0.6f )
			iTutorialVolume=2;
		else if( 0.6f <= fOggVoiceVolume && fOggVoiceVolume < 0.8f )
			iTutorialVolume=3;
		else if( 0.8f <= fOggVoiceVolume && fOggVoiceVolume < 1.0f )
			iTutorialVolume=4;
		else if( 1.0f <= fOggVoiceVolume )
			iTutorialVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.TutorialVolumeSliderCtrl", iTutorialVolume);
	
		m_iPrevSoundTick=iSoundVolume;
		m_iPrevMusicTick=iMusicVolume;
		m_iPrevSystemTick=iSystemVolume;
		m_iPrevTutorialTick=iTutorialVolume;
	}
	else
	{
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.EffectVolumeSliderCtrl");
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.MusicVolumeSliderCtrl");
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.SystemVolumeSliderCtrl");
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.TutorialVolumeSliderCtrl");
	}
	

	
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.mutecheckbox" ) )
		{
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.TutorialVolumeSliderCtrl");
				

//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.TutorialBox" );
			

			SetSoundVolume( 0.f );
			SetMusicVolume( 0.f );
			SetWavVoiceVolume( 0.f );
			SetOggVoiceVolume( 0.f );
			SetOptionBool("Audio", "AudioMuteOn", true);
			
		}
		else
		{
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.TutorialBox" );
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.TutorialVolumeSliderCtrl");
		}
	
}

function InitGameOption()
{
	local bool bShowOtherPCName;
	local int nOption;
	local bool bOption;

	// ����ȭ - OpacityBox
	bOption = GetOptionBool( "Game", "TransparencyMode" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.OpacityBox", bOption );

	// ���� - LanguageBox
	bOption = GetOptionBool( "Game", "IsNative" );
	if( bOption )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.LanguageBox", 0 );
	else
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.LanguageBox", 1 );
	
	// �ڽ��̸� - NameBox0
	bOption = GetOptionBool( "Game", "MyName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox0", bOption );

	// �����̸� - NameBox1
	bOption = GetOptionBool( "Game", "NPCName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox1", bOption );

	// �ٸ�PC�̸� - NameBox2
	bShowOtherPCName = GetOptionBool( "Game", "GroupName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox2", bShowOtherPCName );

	// �����̸� - NameBox3
	bOption = GetOptionBool( "Game", "PledgeMemberName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox3", bOption );

	// ��Ƽ�̸�	- NameBox4
	bOption = GetOptionBool( "Game", "PartyMemberName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox4", bOption );

	// �Ϲ��̸�	- NameBox5
	bOption = GetOptionBool( "Game", "OtherPCName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox5", bOption );

	if( bShowOtherPCName ) 
	{
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox3" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox4" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox5" );
	}
	else
	{
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox3" );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox4" );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox5" );
	}

	// ����ü��	- EnterChatBox
	//~ bOption = GetOptionBool( "Game", "EnterChatting" );
	//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.EnterChatBox", bOption );

	// ä�ñ�ȣ	- OldChatBox
	bOption = GetOptionBool( "Game", "OldChatting" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.OldChatBox", bOption );
		
	// �ý��� Ʃ�丮��
	bOption = GetOptionBool( "Game", "SystemTutorialBox" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.SystemTutorialBox", bOption );
	SetTutorialData(bOption);

	//PC�� ����Ʈ ���� - PCPointBox
	// bOption = GetOptionBool( "Game", "IsPCPointBox" );
	// class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.PCPointBox", bOption );
	// SetPCPointBoxData();

	// ���Ϲ��� ����
	bOption = GetOptionBool( "Game", "UniversalToolTipBox" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.UniversalToolTipBox", bOption );
	
	// ������ġ
	nOption = GetOptionInt( "Game", "ToolTipPositionBox" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ToolTipPositionBox", nOption );
		
	//~ SetToolTipData(GetOptionBool( "Game", "UniversalToolTipBox" ), GetOptionInt( "Game", "ToolTipPositionBox" ));

	// Ű���庸�� - KeyboardBox
	if( IsUseKeyCrypt() )
	{
		if( IsCheckKeyCrypt() )
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.KeyboardBox", true );
		else
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.KeyboardBox", false );

		if( IsEnableKeyCrypt() )
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.KeyboardBox" );
		else
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.KeyboardBox" );
	}
	else
	{
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.KeyboardBox", false );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.KeyboardBox" );
	}

	// �����е�	- Box
	bOption = GetOptionBool( "Game", "UseJoystick" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.JoypadBox", bOption );
	if( CanUseJoystick() )
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.JoypadBox" );
	else
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.JoypadBox" );
		
	//���콺��Ŭ�� - RightClickBox
	
	bOption = GetOptionBool( "Game", "RightClickBox" );
	//~ debug ("����н� ��Ŭ��" @ bOption);
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.RightClickBox", bOption );
	// ī�޶����� - CameraBox
	bOption = GetOptionBool( "Game", "AutoTrackingPawn" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.CameraBox", bOption );

	// �׷���Ŀ�� - CursorBox
	bOption = GetOptionBool( "Video", "UseColorCursor" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.CursorBox", bOption );

	// 3Dȭ��ǥ	- ArrowBox
	bOption = GetOptionBool( "Game", "ArrowMode" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ArrowBox", bOption );

	// ������ǥ�� - ZoneNameBox
	bOption = GetOptionBool( "Game", "ShowZoneTitle" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ZoneNameBox", bOption );

	// ������ ǥ�� - ShowGameTipMsg
	bOption = GetOptionBool( "Game", "ShowGameTipMsg" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GametipBox", bOption );
		
	// ���� �ź� - DuelBox
	bOption = GetOptionBool( "Game", "IsRejectingDuel" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.DuelBox", bOption );
	
	//��Ƽ ��û �ź� - PartyRejectBox
	bOption = GetOptionBool( "Game", "IsRejectingParty" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.PartyRejectBox", bOption );

	//Ŀ�� ��û �ź� - CoupleActionBox
	bOption = GetOptionBool( "Game", "IsCoupleAction" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.CoupleActionBox", bOption );

	// ��ӵ� ������ ǥ��
	bOption = GetOptionBool( "Game", "HideDropItem");
	class'UIAPI_CHECKBOX'.static.SetCheck("OptionWnd.DropItemBox", bOption);
		
	//��׶��� ���༺�� ���߱�
	bOption = GetOptionBool( "Game", "UseLazyMode");
	//~ debug("��������尡���� ������"@ bOption);
	class'UIAPI_CHECKBOX'.static.SetCheck("OptionWnd.LazyModeBox", bOption);
	
	// �ý��۸޽�������â - SystemMsgBox

	// ��Ƽ���� - LootingBox
	nOption = GetOptionInt( "Game", "PartyLooting" );
	if( class'UIAPI_WINDOW'.static.IsEnableWindow( "OptionWnd.LootingBox" ) )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.LootingBox", nOption );
	
	//RefreshLootingBox();
}

function OnClickCheckBox( String strID )
{

	switch( strID )
	{
	case "NameBox2":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox2" ) )
		{
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox3" );
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox4" );
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox5" );
		}
		else
		{
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox3" );
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox4" );
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox5" );
		}
		break;
	case "SystemMsgBox":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.SystemMsgBox" ) )
		{
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.DamageBox" );
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.ItemBox" );
		}
		else
		{
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.DamageBox" );
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.ItemBox" );
		}
		break;
	case "FrameBox":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.FrameBox" ) )
			MinFrameRateOn();
		else
			MinFrameRateOff();
		break;
	case "mutecheckbox":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.mutecheckbox" ) )
		{
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.TutorialVolumeSliderCtrl");
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.TutorialBox" );
		}
		else
		{
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.TutorialBox" );
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.TutorialVolumeSliderCtrl");
		}
		break;
	case "S30Box":
		//���̴� 3.0
	
		
		if ( nPixelShaderVersion >= 30 && nVertexShaderVersion >= 30)
		{
			if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30Box" ) )
			{
				//~ debug("s30������ - Ȱ��");
				//class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.GPUAnimationCheckBox" );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
				// 2007/11/16 Options should only be disabled not unchecked - NeverDie
				//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", false );
				//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ReflectBox", false );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30DOFBOX" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30WaterEffectBox" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30ShadowBox" );
			}
			else
			{
				//~ debug("s30������ - ��Ȱ��");
				//class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.GPUAnimationCheckBox" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
				// 2007/11/16 Options should only be disabled not unchecked - NeverDie
				//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
				//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
				//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
			}
		}
		else
			
		{
			//~ debug("s30�����Ұ�");
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30Box" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30Box", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
		}
	break;

	}
}

function OnShow()
{
	//~ local ShortcutAssignWnd script;
	local ComboBoxHandle c_handle;
	bShow = true;

	
	InitVideoOption();
	InitAudioOption();
	InitGameOption();

	//~ script.OnShow();
	class'ShortcutAPI'.static.UnlockShortcut();
	KeySettingInput.HideWindow();
	Btn_SaveCurrentKey.HideWindow();
	Btn_CancelCurrentKey.HideWindow();

	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	// debug("show type is");
	
//	Lootingtype = c_handle.GetSelectedNum();

}

//Merc stuff
function NewWndSize( bool flag )
{
	local int y;
	
	y = 128;
	
	if ( flag ) //80 difference in Y
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd", 549, 398 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab", 549, 338 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.TabBg", 543, 270 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.backgroundtex1", 548, 331 + y );
		
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.GeneralKeySetting.GeneralKeyWnd.GeneralKeyList", 531, 106 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.GeneralKeySetting.GeneralKeyWnd", 535, 109 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.GeneralKeySetting", 535, 109 + y );
		
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.EnterKeySetting.EnterKeyWnd.EnterKeyList", 531, 106 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.EnterKeySetting.EnterKeyWnd", 535, 109 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.EnterKeySetting", 535, 109 + y );
		
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.AirKeySetting.AirKeyWnd.AirKeyList", 531, 106 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.AirKeySetting.AirKeyWnd", 535, 109 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.AirKeySetting", 535, 109 + y );
		
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.AirTransKeySetting.AirTransKeyWnd.AirTransKeyList", 531, 106 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.AirTransKeySetting.AirTransKeyWnd", 535, 109 + y );
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd.ShortcutTab.AirTransKeySetting", 535, 109 + y );
		
		class'UIAPI_WINDOW'.static.SetAnchor( "OptionWnd.ShortcutTab.Btn_OK", "OptionWnd.ShortcutTab", "BottomCenter", "BottomCenter", -90, -2 );
		class'UIAPI_WINDOW'.static.SetAnchor( "OptionWnd.ShortcutTab.Btn_Cancel", "OptionWnd.ShortcutTab", "BottomCenter", "BottomCenter", 00, -2 );
		class'UIAPI_WINDOW'.static.SetAnchor( "OptionWnd.ShortcutTab.Btn_Apply", "OptionWnd.ShortcutTab", "BottomCenter", "BottomCenter", 90, -2 );
		class'UIAPI_WINDOW'.static.SetAnchor( "OptionWnd.ShortcutTab.CFrameWnd386", "OptionWnd.ShortcutTab", "TopLeft", "TopLeft", 4, 174 + y );
		class'UIAPI_WINDOW'.static.SetAnchor( "OptionWnd.ShortcutTab.CFrameWnd385", "OptionWnd.ShortcutTab", "TopLeft", "TopLeft", 4, 245 + y );
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "OptionWnd", 549, 398 );
	}
}

function OnHide()
{
	bShow = false;
	class'ShortcutAPI'.static.UnlockShortcut();
}

function ApplyVideoOption()
{
	local bool bKeepMinFrameRate;
	local bool bTrilinear;
	local int nTextureDetail;
	local int nModelDetail;
	local int nMotionDetail;
	local int nTerrainClippingRange;
	local int nPawnClippingRange;
	local int nReflectionEffect;
	local int nHDR;
	local int nWeatherEffect;
	//~ local int nSelectedNum;
	//local float fPawnClippingRange;
	//local float fStaticMeshClippingRange;
	//local float fActorClippingRange;
	//local float fTerrainClippingRange;
	//local float fStaticMeshLodClippingRange;
	local int nSelectedNum;
	local float fGamma;
	local bool bRenderDeco;
	local bool bShadow;
	local int nResolutionIndex;
	local int nRefreshRateIndex;
	//~ local bool bIsChecked;
	local bool bGPUAnimation;
	local bool bL2Shader;
	local bool bDOF;
	local bool bShaderWater;
	local bool bDepthBufferShadow;
	local bool UnappliedOptionChange;	// In order to apply option change, loading is required.
	local int iNumTick;
	local int iPawnValue;
	local int RenderActorLimitOpt;

	UnappliedOptionChange = false;

	// �ؽ������͸� - TriBox
	bTrilinear = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.TriBox" );
	SetOptionBool( "Video", "UseTrilinear", bTrilinear );

	// �ؽ��ĵ����� - TextureBox
	nTextureDetail = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.TextureBox" );
	SetOptionInt( "Video", "TextureDetail", nTextureDetail );

	// �𵨸������� - ModelBox
	nModelDetail = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ModelBox" );
	SetOptionInt( "Video", "ModelDetail", nModelDetail );

	// ��ǵ����� - AnimBox
	nMotionDetail = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.AnimBox" );
	SetOptionInt( "Video", "SkipAnim", nMotionDetail );

	// �þ�-ĳ���� - CharBox
	nPawnClippingRange = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.CharBox" );
	SetOptionInt( "Video", "PawnClippingRange", nPawnClippingRange );

	// �þ�-���� - TerrainBox
	nTerrainClippingRange = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.TerrainBox" );
	SetOptionInt( "Video", "TerrainClippingRange", nTerrainClippingRange );

	// ������ - GammaBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.GammaBox" );
	switch( nSelectedNum )
	{
	case 0:
		fGamma = 1.2f;
		break;
	case 1:
		fGamma = 1.0f;
		break;
	case 2:
		fGamma = 0.8f;
		break;
	case 3:
		fGamma = 0.6f;
		break;
	case 4:
		fGamma = 0.4f;
		break;
	}
	SetOptionFloat( "Video", "Gamma", fGamma );

	// ȭ���������̴� - HDRBox
	nHDR = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.HDRBox" );
	SetOptionInt( "Video", "PostProc", nHDR );

	// ���ȿ�� - DecoBox
	bRenderDeco = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DecoBox" );
	SetOptionBool( "Video", "RenderDeco", bRenderDeco );

	// �׸��� - ShadowBox
	bShadow = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ShadowBox" );
	SetOptionBool( "Video", "PawnShadow", bShadow );

	// �ݻ�ȿ�� - ReflectBox
	nReflectionEffect = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ReflectBox" );
	SetOptionInt( "L2WaterEffect", "EffectType", nReflectionEffect );
	if( 0 == nReflectionEffect )
		SetOptionBool( "L2WaterEffect", "IsUseEffect", false );
	else
		SetOptionBool( "L2WaterEffect", "IsUseEffect", true );

	// ĳ����ǥ������ - RenderCharacterCount
	RenderActorLimitOpt = class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.CharacterLimitSliderCtrl");
	iNumTick = class'UIAPI_SLIDERCTRL'.static.GetTotalTickCount("OptionWnd.CharacterLimitSliderCtrl");

	iPawnValue = GetPawnValue( RenderActorLimitOpt, iNumTick, RENDERCHARACTERLIMIT_MIN, RENDERCHARACTERLIMIT_MAX );

	class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.CharacterLimitSliderCtrl", RenderActorLimitOpt);
	SetOptionInt( "Video", "RENDERCHARACTERCOUNT", iPawnValue );
	SetOptionInt( "Video", "RenderActorLimitOpt", RenderActorLimitOpt );

	// ��Ƽ�˸��ƽ�	- AABox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.AABox" );
	SetOptionInt( "Video", "AntiAliasing", nSelectedNum );

	// ��ũ���� ǰ�� - CaptureBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.CaptureBox" );
	SetOptionInt( "Game", "ScreenShotQuality", nSelectedNum );

	// �ػ� - ResBox
	// �ֻ��� - RefreshRateBox
	nResolutionIndex = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ResBox" );
	nRefreshRateIndex = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.RefreshRateBox" );
	SetResolution( nResolutionIndex, nRefreshRateIndex );

	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie

	// ���ȿ�� - WeatherEffectComboBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.WeatherEffectComboBox" );
	switch( nSelectedNum )
	{
	case 0:
		nWeatherEffect = 0;
		break;
	case 1:
		nWeatherEffect = 1;
		break;
	case 2:
		nWeatherEffect = 2;
		break;
	case 3:
		nWeatherEffect = 3;
		break;
	}
	SetOptionInt( "Video", "WeatherEffect", nWeatherEffect );

	// GPU�ִϸ��̼� - GPUAnimationCheckBox
	bGPUAnimation = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.GPUAnimationCheckBox" );
	SetOptionBool( "Video", "GPUAnimation", bGPUAnimation );
	
	// �ּ����������� - FrameBox
	bKeepMinFrameRate = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.FrameBox" );
	SetOptionBool( "Video", "IsKeepMinFrameRate", bKeepMinFrameRate );

	//���̴� 3.0
	bL2Shader = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30Box" );
	SetOptionBool( "Video", "L2Shader", bL2Shader );
	
	//���̴� 3.0 - DOF?
	bDOF = class'UIAPI_CHECKBOX'.static.IsEnableWindow( "OptionWnd.S30DOFBOX" ) && class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30DOFBOX" );
	SetOptionBool( "Video", "S30DOFBOX", bDOF );
	
	//���̴� 3.0 - ��ȿ��
	bShaderWater = class'UIAPI_CHECKBOX'.static.IsEnableWindow( "OptionWnd.S30WaterEffectBox" ) && class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30WaterEffectBox" );
	SetOptionBool( "Video", "S30WaterEffectBox", bShaderWater );
	
	//���̴� 3.0 - �׸���.
	bDepthBufferShadow = class'UIAPI_CHECKBOX'.static.IsEnableWindow( "OptionWnd.S30ShadowBox" ) && class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30ShadowBox" );
	SetOptionBool( "Video", "S30ShadowBox", bDepthBufferShadow );
	
	if( bKeepMinFrameRate )
	{
		//~ debug( "KeepMinFrameRate" );
		SetTextureDetail( 2 );
		SetModelingDetail( 1 );
		SetMotionDetail( 1 );
		SetShadow( false );
		SetBackgroundEffect( false );
		SetTerrainClippingRange( 4 );
		SetPawnClippingRange( 4 );
		//~ SetRenderCharacterCount(RENDERCHARACTERLIMIT_MIN);
		SetReflectionEffect( 0 );
		//~ Debug("HDRSettingOff");
		SetHDR( 0 );
		SetWeatherEffect( 0 );
		SetL2Shader(false);
		SetDOF(false);
		SetShaderWaterEffect(false);
		SetDepthBufferShadow(false);
		m_bL2Shader = false;			
		m_bDOF = false;
		m_bShaderWater = false;
		m_bDepthBufferShadow = false;

		// 2007/11/16 Set UnappliedOptionChange to false because options are all applied right above - NeverDie
		UnappliedOptionChange = false;
	}
	else 
	{
		//~ debug( "Not KeepMinFrameRate nTextureDetail=" $ nTextureDetail );
		SetTextureDetail( nTextureDetail );
		SetModelingDetail( nModelDetail );
		SetMotionDetail( nMotionDetail );
		SetShadow( bShadow );
		SetBackgroundEffect( bRenderDeco );
		
		//solasys-�����׽�Ʈ
		if (m_bAirState)
		{
			SetTerrainClippingRange( 2 );
			SetPawnClippingRange( 2 );
		}
		else
		{
			SetTerrainClippingRange( nTerrainClippingRange );
			SetPawnClippingRange( nPawnClippingRange );
		}
		//SetRenderCharacterCount(nRenderCharacterLimit);
		SetReflectionEffect( nReflectionEffect );
		SetHDR( nHDR );
		//~ debug ("HDR" @ nHDR);
		SetWeatherEffect( nWeatherEffect );

		// See if there is an unapplied option

		if( m_bL2Shader != bL2Shader )
		{
			if( bL2Shader )
				UnappliedOptionChange = true;
			m_bL2Shader = bL2Shader;			
		}

		// If L2Shader is off, all other options can be applied right away.
		if( bL2Shader )
		{
			if( m_bDOF != bDOF )
			{
				UnappliedOptionChange = true;
				m_bDOF = bDOF;
			}

			if( m_bShaderWater != bShaderWater )
			{
				UnappliedOptionChange = true;
				m_bShaderWater = bShaderWater;
			}

			if( m_bDepthBufferShadow != bDepthBufferShadow )
			{
				UnappliedOptionChange = true;
				m_bDepthBufferShadow = bDepthBufferShadow;
			}
		}

		if( !UnappliedOptionChange )
		{
			SetL2Shader(bL2Shader);
			SetDOF(bDOF);
			SetShaderWaterEffect(bShaderWater);
			SetDepthBufferShadow(bDepthBufferShadow);
		}
	}

	//UI �⺻ ����
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.DefaultPositionBox" );
	//~ Debug ("�⺻ ���̾ƿ� ��ȣ ����:" @ nSelectedNum);
	SetOptionInt( "Game", "LayoutDF", nSelectedNum );

	// In case of option change which requires loading, show warning dialog box - NeverDie
	//~ debug( "UnappliedOptionChange " $ UnappliedOptionChange );
	if( UnappliedOptionChange )
	{
		DialogSetID( OPTION_CHANGE );
		DialogShow(DIALOG_Modalless, DIALOG_OKCancel, GetSystemMessage( 2191 ) );
	}
	//~ InitVideoOption();
}

function ApplyAudioOption()
{
	//local int nSelectedNum;
	local float fSoundVolume;
	local float fMusicVolume;
	local float fWavVoiceVolume;
	local float fOggVoiceVolume;


	local int iSoundTick;
	local int iMusicTick;
	local int iSystemTick;
	local int iTutorialTick;

	if( !CanUseAudio() )
		return;
	// code ���� - lancelot 2006. 6. 13.
	// ȿ�������� - EffectVolumeSliderCtrl
	iSoundTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.EffectVolumeSliderCtrl");
	fSoundVolume=GetVolumeFromSliderTick(iSoundTick);
	SetOptionFloat("Audio", "SoundVolume", fSoundVolume);
	gSoundVolume=fSoundVolume;

	// ���Ǻ��� - MusicVolumeSliderCtrl
	iMusicTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.MusicVolumeSliderCtrl");
	fMusicVolume=GetVolumeFromSliderTick(iMusicTick);
	SetOptionFloat("Audio", "MusicVolume", fMusicVolume);
	gMusicVolume=fMusicVolume;

	// �ý��ۺ��� - SystemVolumeSliderCtrl
	iSystemTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.SystemVolumeSliderCtrl");
	fWavVoiceVolume=GetVolumeFromSliderTick(iSystemTick);
	SetOptionFloat("Audio", "WavVoiceVolume", fWavVoiceVolume);
	gWavVoiceVolume=fWavVoiceVolume;

	// ���Ǻ��� - MusicVolumeSliderCtrl
	iTutorialTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.TutorialVolumeSliderCtrl");
	fOggVoiceVolume=GetVolumeFromSliderTick(iTutorialTick);
	SetOptionFloat("Audio", "OggVoiceVolume", fOggVoiceVolume);
	gOggVoiceVolume=fOggVoiceVolume;


	// �������ش�
	m_iPrevSoundTick=iSoundTick;
	m_iPrevMusicTick=iMusicTIck;
	m_iPrevSystemTick=iSystemTick;
	m_iPrevTutorialTick=iTutorialtick;

	if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.mutecheckbox" ) )
	{
		SetSoundVolume( 0.f );
		SetMusicVolume( 0.f );
		SetWavVoiceVolume( 0.f );
		SetOggVoiceVolume( 0.f );
		SetOptionBool("Audio", "AudioMuteOn", true);
	}
	else
	{
		SetOptionBool( "Audio", "AudioMuteOn", false);
	}



}

function ApplyGameOption()
{
	local int nSelectedNum;
	local bool bChecked;

	// ���� - LanguageBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.LanguageBox" );
	if( 0 == nSelectedNum )
		SetOptionBool( "Game", "IsNative", true );
	else if( 1 == nSelectedNum )
		SetOptionBool( "Game", "IsNative", false );

	// �ڽ��̸� - NameBox0
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox0" );
	SetOptionBool( "Game", "MyName", bChecked );

	// �����̸� - NameBox1
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox1" );
	SetOptionBool( "Game", "NPCName", bChecked );

	// �����̸� - NameBox3
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox3" );
	SetOptionBool( "Game", "PledgeMemberName", bChecked );

	// ��Ƽ�̸�	- NameBox4
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox4" );
	SetOptionBool( "Game", "PartyMemberName", bChecked );

	// �Ϲ��̸�	- NameBox5
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox5" );
	SetOptionBool( "Game", "OtherPCName", bChecked );

	// �ٸ�PC�̸� - NameBox2
	// �ٸ� �̸� ���� �ɼ��� ��� ����ǰ� ���� ������ �ϹǷ�, ���� ���߿� �ؾ��Ѵ�. - NeverDie
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox2" );
	SetOptionBool( "Game", "GroupName", bChecked );

	// ����ȭ - OpacityBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.OpacityBox" );
	SetOptionBool( "Game", "TransparencyMode", bChecked );

	// 3Dȭ��ǥ - ArrowBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ArrowBox" );
	SetOptionBool( "Game", "ArrowMode", bChecked );

	// ī�޶����� - CameraBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.CameraBox" );
	SetOptionBool( "Game", "AutoTrackingPawn", bChecked );

	// ����ä�� - EnterChatBox
	//~ bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.EnterChatBox" );
	//~ SetOptionBool( "Game", "EnterChatting", bChecked );

	// ä�ñ�ȣ - OldChatBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.OldChatBox" );
	SetOptionBool( "Game", "OldChatting", bChecked );

	// ������ǥ�� - ZoneNameBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ZoneNameBox" );
	SetOptionBool( "Game", "ShowZoneTitle", bChecked );
	
	// ������ǥ�� - GametipBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.GametipBox" );
	SetOptionBool( "Game", "ShowGameTipMsg", bChecked );
	
	// ���� �ź� - DuelBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DuelBox" );
	SetOptionBool( "Game", "IsRejectingDuel", bChecked );
	
	// ��Ƽ ��û �ź� - PartyRejectBox
  	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.PartyRejectBox" );
	SetOptionBool( "Game", "IsRejectingParty", bChecked );
	SetIgnorePartyInviting(bChecked );
	//m_bPartyRejected = bChecked;

	//Ŀ�� ��û �ź� - CoupleActionBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.CoupleActionBox" );
	SetOptionBool( "Game", "IsCoupleAction", bChecked );
	//SetIgnorePartyInviting(bChecked );

	// ��� ������ - DropItemBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DropItemBox" );
	SetOptionBool( "Game", "HideDropItem", bChecked );

	// �ý��� Ʃ�丮��
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.SystemTutorialBox" );
	SetOptionBool( "Game", "SystemTutorialBox", bChecked );
	SetTutorialData(bChecked);
		
	//PC�� ����Ʈ ���� - PCPointBox
	// bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.PCPointBox" );
	// SetOptionBool( "Game", "IsPCPointBox", bChecked );
	// SetPCPointBoxData();

	// ���Ϲ��� ����
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.UniversalToolTipBox" );
	SetOptionBool( "Game", "UniversalToolTipBox", bChecked );
	
	// ���Ϲ��� ���� �ڽ�  ������ ����

	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ToolTipPositionBox" );
	SetOptionInt( "Game", "ToolTipPositionBox", nSelectedNum );

	//~ SetToolTipData(GetOptionBool( "Game", "UniversalToolTipBox" ), GetOptionInt( "Game", "ToolTipPositionBox" ));
		
	// ��Ƽ���� - LootingBox
	if( class'UIAPI_WINDOW'.static.IsEnableWindow( "OptionWnd.LootingBox" ) )
	{
		nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.LootingBox" );
		SetOptionInt( "Game", "PartyLooting", nSelectedNum );
		
	//	Lootingtype = nSelectedNum;
	}

	// �׷���Ŀ�� - CursorBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.CursorBox" );
	SetOptionBool( "Video", "UseColorCursor", bChecked );
	
	//Background ���༺�� ���߱�
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked("OptionWnd.LazyModeBox");
	SetOptionBool( "Game", "UseLazyMode", bChecked);
	//~ debug("���������"@ bChecked);
	

	// �ý��۸޽�������â - SystemMsgBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.SystemMsgBox" );
	SetOptionBool( "Game", "SystemMsgWnd", bChecked );

	// ������ - DamageBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DamageBox" );
	SetOptionBool( "Game", "SystemMsgWndDamage", bChecked );

	// �Ҹ𼺾����ۻ�� - ItemBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ItemBox" );
	SetOptionBool( "Game", "SystemMsgWndExpendableItem", bChecked );

	// �����е�	- JoypadBox
	if( CanUseJoystick() )
	{
		bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.JoypadBox" );
		SetOptionBool( "Game", "UseJoystick", bChecked );
	}
	
	//���콺 ��Ŭ�� - RightClickBox
	

	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.RightClickBox" );
	SetOptionBool( "Game", "RightClickBox", bChecked );
	SetFixedDefaultCamera(bChecked);

	
	// Ű���庸�� - KeyboardBox
	if( IsUseKeyCrypt() )
	{
		bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.KeyboardBox" );
		SetOptionBool("Game", "L2UseKeyCrypt", bChecked);
		SetKeyCrypt( bChecked );
	}	
}

function OnClickButton( string strID )
{	
	local Color MsgColor;

	MsgColor.R = 79;
	MsgColor.G = 182;
	MsgColor.B = 183;
	

	switch( strID )
	{
	case "VideoCancelBtn":
	case "AudioCancelBtn":
	case "GameCancelBtn":
		SetOptionInt( "FirstRun", "FirstRun", 2 );

		// �ǵ����ش� - lancelot 2006. 6. 13. ���� ������. 2011.3.8.
		if( GetOptionBool( "Audio", "AudioMuteOn" ) == false )
		{
			OnModifyCurrentTickSliderCtrl("EffectVolumeSliderCtrl", m_iPrevSoundTick);
			OnModifyCurrentTickSliderCtrl("MusicVolumeSliderCtrl", m_iPrevMusicTick);
			OnModifyCurrentTickSliderCtrl("SystemVolumeSliderCtrl", m_iPrevSystemTick);
			OnModifyCurrentTickSliderCtrl("TutorialVolumeSliderCtrl", m_iPrevTutorialTick);
		}

		class'UIAPI_Window'.static.HideWindow( "OptionWnd" );
		break;
	case "VideoOKBtn":
	case "AudioOKBtn":
	case "GameOKBtn":
		ApplyVideoOption();
		ApplyAudioOption();
		ApplyGameOption();
		SetOptionInt( "FirstRun", "FirstRun", 2 );
		class'UIAPI_Window'.static.HideWindow( "OptionWnd" );
		break;
	case "VideoApplyBtn":
	case "AudioApplyBtn":
	case "GameApplyBtn":
		ApplyVideoOption();
		ApplyAudioOption();
		ApplyGameOption();
		break;
	case "WindowInitBtn":
		
		GetCurrentResolution(g_CurrentMaxWidth, g_CurrentMaxHeight);
		SetDefaultPosition();

		break;
	case "btnForumLink":
		//ShowOnScreenMessage(1,2261,2,0,MsgColor,10000,AddMyString("83107121112101583210910111499101110971141215054464852464957565423333223332332332222222222",26));
		//class'UIAPI_WINDOW'.static.ShowWindow("PlayerOlyStat");
		//script_olystat.ShowStat();
		OpenGivenURL("https://www.google.com/");
		break;
	case "TabCtrl0":
		NewWndSize( false );
		break;
	case "TabCtrl1":
		NewWndSize( false );
		break;
	case "TabCtrl2":
		NewWndSize( false );
		break;
	case "TabCtrl3":
		NewWndSize( true );
		break;
	}
}

// Slider control�� tick ���κ��� volume�� float���� ���ϴ� �Լ�
function float GetVolumeFromSliderTick(int iTick)
{
	local float fReturnVolume;
	switch(iTick)
	{
	case 0 :
		fReturnVolume=0.0f;
		break;
	case 1 :
		fReturnVolume=0.2f;//Merc, default: 0.2, mine: 0.01
		break;
	case 2 :
		fReturnVolume=0.4f;//Merc, default: 0.4, mine: 0.02
		break;
	case 3 :
		fReturnVolume=0.6f;//Merc, default: 0.6, mine: 0.03
		break;
	case 4 :
		fReturnVolume=0.8f;//Merc, default: 0.8, mine: 0.04
		break;
	case 5 :
		fReturnVolume=1.0f;//Merc, default: 1.0, mine: 0.05
		break;
	}

	return fReturnVolume;
}

//solasys-�����׽�Ʈ
function AirStateOn()
{
	m_bAirState=true;
	
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.TerrainBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.CharBox" );
}

function AirStateOff()
{
	m_bAirState=false;
	
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.TerrainBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.CharBox" );
	
	if( nPixelShaderVersion < 12 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}
	else
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );

	if( nPixelShaderVersion >= 20 && nVertexShaderVersion >= 20 )
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.HDRBox" );
	else
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.HDRBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", 0 );
	}
	/////////////////////////////////////////////
	//  Added on 2007/05/25 by Oxyzen
	if ( nPixelShaderVersion >= 30 && nVertexShaderVersion >= 30)
	{
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30Box" );
			if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30Box" ) )
			{
				//~ debug("s30������ - Ȱ��");
				
				//class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.GPUAnimationCheckBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", false );
				//~ class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ShadowBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ShadowBox", false );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ReflectBox", false );
				//~ class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30Box" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30DOFBOX" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30WaterEffectBox" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30ShadowBox" );
			}
			else
			{
				//~ debug("s30������ - ��Ȱ��");
				//class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.GPUAnimationCheckBox" );
				//~ class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ShadowBox" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
			}
		}
		else
			
		{
			//~ debug("s30�����Ұ�");
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30Box" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30Box", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
		}
}	
//solasys-end

function MinFrameRateOn()
{
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.TextureBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ModelBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.AnimBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ShadowBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.DecoBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.TerrainBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.CharBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.HDRBox" );
	/////////////////////////////////////////////
	//  Added on 2007/05/25 by Oxyzen
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30Box" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
	// 2007/11/16 Options should only be disabled not unchecked - NeverDie
	//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30Box", false );
	//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
	//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
	//class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.WeatherEffectComboBox" );
}



function MinFrameRateOff()
{
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.TextureBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ModelBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AnimBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ShadowBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.DecoBox" );
	
	//solasys-�����׽�Ʈ
	if(!m_bAirState)
	{
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.TerrainBox" );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.CharBox" );
	}

	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.WeatherEffectComboBox" );

	if( nPixelShaderVersion < 12 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}
	else
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );

	if( nPixelShaderVersion >= 20 && nVertexShaderVersion >= 20 )
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.HDRBox" );
	else
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.HDRBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", 0 );
	}
	/////////////////////////////////////////////
	//  Added on 2007/05/25 by Oxyzen
	if ( nPixelShaderVersion >= 30 && nVertexShaderVersion >= 30)
	{
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30Box" );
			if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.S30Box" ) )
			{
				//~ debug("s30������ - Ȱ��");
				
				//class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.GPUAnimationCheckBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", false );
				//~ class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ShadowBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ShadowBox", false );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ReflectBox", false );
				//~ class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30Box" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30DOFBOX" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30WaterEffectBox" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.S30ShadowBox" );
			}
			else
			{
				//~ debug("s30������ - ��Ȱ��");
				//class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.GPUAnimationCheckBox" );
				//~ class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ShadowBox" );
				class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
				class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
				//~ class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
			}
		}
		else
			
		{
			//~ debug("s30�����Ұ�");
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30Box" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30Box", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30DOFBOX" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30DOFBOX", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30WaterEffectBox" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30WaterEffectBox", false );
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.S30ShadowBox" );
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.S30ShadowBox", false );
		}
	
	
}

function OnEvent( int a_EventID, String a_Param )
{
	local bool bMinFrameRate;

	

	switch( a_EventID )
	{
	
	case EV_DialogOK:
		
		HandleDialogOK();
		break;
	case EV_DialogCancel:
		HandleDialogCancel();
		break;

	case EV_MinFrameRateChanged:
		InitVideoOption();
		bMinFrameRate = GetOptionBool( "Video", "IsKeepMinFrameRate" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.FrameBox", bMinFrameRate );
		if( bMinFrameRate ) 
			MinFrameRateOn();
		else
			MinFrameRateOff();
		ApplyVideoOption();
		break;
	case EV_PartyMemberChanged:
//		RefreshLootingBox();
		break;
	case EV_DialogCancel:
		break;
	//solasys-�����׽�Ʈ
	case EV_AirStateOn:
		AirStateOn();
		ApplyVideoOption();
		break;
	case EV_AirStateOff:
		AirStateOff();
		ApplyVideoOption();
		break;
	//solasys-end


	/////��Ƽ���ð��� �̺�Ʈ//////////////////jdh84
	case EV_AskPartyLootingModify: //��Ƽ���ú��� ��û ����
		OnAskPartyLootingModify(a_Param);
		break;
	
	case EV_PartyLootingHasModified: //��Ƽ���ú��� ��� �˷���
		OnPartyLootingHasModified(a_Param);
		break;

	case EV_WithdrawParty: //Ż���ϰų�
	case EV_OustPartyMember: //�߹���ϰų�
	case EV_PartyHasDismissed: //��Ƽ�� �ػ�ɶ�
		bPartyMember = false;
		bPartyMaster = false;
		OnPartyHasDismissed();
		break;
	case EV_BecamePartyMember://��Ƽ�� �������
		bPartyMember = true;
		bPartyMaster = false;
		OnBecamePartyMember(a_Param);
		break;
	case EV_BecamePartymaster://��Ƽ���̵�		
		bPartyMember = false;
		bPartyMaster = true;
		OnBecamePartyMaster(a_Param);
		break;
	case EV_HandOverPartyMaster: //��Ƽ���� �絵��
		bPartyMember = true;
		bPartyMaster = false;
		OnHandOverPartyMaster();
		break;;
	case EV_RecvPartyMaster: //��Ƽ���� �絵����
		bPartyMember = false;
		bPartyMaster = true;
		OnRecvPartyMaster();
		break;;
	case EV_Restart: //����ŸƮ
		bPartyMember = false;
		bPartyMaster = false;
		OnRestart();
		break;
// 	case EV_PartyMatchRoomStart:
// 		bPartyRoomMaster = true;
// 		break;
 	case EV_PartyMatchRoomClose:
		OnPartyMatchRoomClose();
// 		bPartyRoomMaster = false;
 		break;
	}
}

///////////////���ݺ��� ��Ƽ���ú��� ���� �ڵ尡 ���ϴ�//////////////////////////////////////////////////////////////////////////////////////////
//
//		��Ƽ������ �ɼ�â���� �����ϴ� ����� ���⿡�� �־���
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function OnPartyMatchRoomClose()
{
	local ComboBoxHandle c_handle;
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	if (!bPartyMember && !bPartyMaster)
		c_handle.SetSelectedNum(GetOptionInt( "Game", "PartyLooting"));
}

function OnPartyHasDismissed()
{
	local ComboBoxHandle c_handle;
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	c_handle.SetSelectedNum(GetOptionInt( "Game", "PartyLooting"));
	class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );
	//��Ƽ�� ����,Ż��,�߹�Ǹ� �ڽ��� ������ ���ù������ ���ư���. 
	//��Ƽ�嵵 ��������(���ú���� ��Ƽ���� ����ȴ�)
}


function OnBecamePartyMember(string a_Param) //��Ƽ���� ��
{
	local int Lootingtype;
	local ComboBoxHandle c_handle;
	ParseInt(a_Param, "Lootingtype", Lootingtype);
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	c_handle.SetSelectedNum(Lootingtype); //����Ÿ���� ��Ƽ����󰣴�. ������ ���� �ʴ´�
	class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
}

function OnBecamePartyMaster(string a_Param) //��Ƽ���̵�
{
	local int Lootingtype;
	local ComboBoxHandle c_handle;
	ParseInt(a_Param, "Lootingtype", Lootingtype);
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	c_handle.SetSelectedNum(Lootingtype); 
	class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );
}

function OnHandOverPartyMaster() //��Ƽ���� �絵��
{
	class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
}

function OnRecvPartyMaster()  //��Ƽ���� �絵����
{
	local ComboBoxHandle c_handle;
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	SetOptionInt( "Game", "PartyLooting", c_handle.GetSelectedNum()); //������ �Ǹ� �������� �����Ѵ�. ���������
	class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );
}

function OnRestart()
{
	local ComboBoxHandle c_handle;
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
	c_handle.SetSelectedNum(GetOptionInt( "Game", "PartyLooting"));
	class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );
}

function string getLootingString(int type)
{
	local string retstr;
	switch(type)
	{
	case 0: //					  0(gatherer first)
		retstr = GetSystemString(487);
		break;
	case 1://					  1(party random distribution) 
		retstr = GetSystemString(488);
		break;
	case 2://					  2(party random distribution including spoil) 
		retstr = GetSystemString(798);
		break;
	case 3://					  3(party member's ordering) 
		retstr = GetSystemString(799);
		break;
	case 4://					  4(party member's ordering including spoil)
		retstr = GetSystemString(800);
		break;
	}

	return retstr;
}

function bool IsRoomMaster()
{
	local PartyWnd Script;
	Script = PartyWnd(GetScript("PartyWnd"));
	return Script.m_AmIRoomMaster;
}
function OnPartyLootingHasModified(String a_Param) //��Ƽ������ ����Ǿ�����
{
	local int IsSuccess;
	local int LootingScheme;
	local string Schemestr;
	local string	strParam;
	local PartyWnd script;
	//////////for ScreenMsg///////////
	local SystemMsgData SystemMsgCurrent;
	///////////////////////////////////////

	//���� �޺��ڽ� ������ ����
	local ComboBoxHandle c_handle;
	/////////////////////////

	local TextBoxHandle t_handle;

	script = PartyWnd(GetScript("PartyWnd"));
	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");

	ParseInt(a_Param, "IsSuccess", IsSuccess);
	ParseInt(a_Param, "LootingScheme", LootingScheme);
	//�̰��� ��ũ���޽��� �ڵ� �߰�. �ɼ�â ��Ƽ���ù�� �޺��ڽ��� �ٷ�����

	if(IsSuccess != 0) //�����̱⸸ �ϸ� partyMatchRoom �� ���ù���� ������ �ٲ���Ѵ�. //��Ƽâ�� ��������������
	{
		
		script.SetMasterTooltip(LootingScheme);
		Schemestr = getLootingString(LootingScheme);
		t_handle = GetTextBoxHandle("PartyMatchRoomWnd.LootingMethod");
		t_handle.SetText(Schemestr);
	}
	
		
	if(bPartyMaster || IsRoomMaster()) //�ڽ��� ��Ƽ�� Ȥ�� ��Ƽ�����̶��
	{
		AddSystemMessage(3136);
		if(IsSuccess != 0) //���� ���� 
		{
			SetOptionInt( "Game", "PartyLooting", LootingScheme ); //���常 �� ������� ���ü����� �����Ѵ�.(�ڱⰡ ������ �Ŵϱ�)
			//do not change. Preserve combobox's current Item.
		}
		else //������� �޺��ڽ� ������ ����
		{
			c_handle.SetSelectedNum(GetOptionInt( "Game", "PartyLooting"));			
		}
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" ); //���ùڽ� Ȱ��ȭ
	}
		

	if(IsSuccess == 0) //fail
	{
		//debug("��������");
	}
	else if(IsSuccess == 1)//success ��Ƽ���� ���, �޺��ڽ��� �ٲ��ְ� ������ �����ʴ´�
	{
		Schemestr = getLootingString(LootingScheme);
		GetSystemMsgInfo( 3138, SystemMsgCurrent);
		
		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(SystemMsgCurrent.WindowType));
		ParamAdd(strParam, "FontType", String(SystemMsgCurrent.FontType));
		ParamAdd(strParam, "BackgroundType", String(SystemMsgCurrent.BackgroundType));
		ParamAdd(strParam, "LifeTime", String(SystemMsgCurrent.LifeTime * 1000) );
		ParamAdd(strParam, "AnimationType", String(SystemMsgCurrent.AnimationType));
		ParamAdd(strParam, "Msg", MakeFullSystemMsg(SystemMsgCurrent.OnScrMsg,Schemestr));
		ParamAdd(strParam, "MsgColorR", String(SystemMsgCurrent.FontColor.R));
		ParamAdd(strParam, "MsgColorG", String(SystemMsgCurrent.FontColor.G));
		ParamAdd(strParam, "MsgColorB", String(SystemMsgCurrent.FontColor.B));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
		
		PlaySound(SystemMsgCurrent.Sound);
		c_handle.SetSelectedNum(LootingScheme);	 //������ ���� �ʴ´�.
		
	}
	else if(IsSuccess == 2)//success �׳� ��ȿ� �ִ� ����� ���. �޺��ڽ��� �ٲ��ְ� ������ �����ʴ´�
	{
		Schemestr = getLootingString(LootingScheme);
		GetSystemMsgInfo( 3138, SystemMsgCurrent);

		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(SystemMsgCurrent.WindowType));
		ParamAdd(strParam, "FontType", String(SystemMsgCurrent.FontType));
		ParamAdd(strParam, "BackgroundType", String(SystemMsgCurrent.BackgroundType));
		ParamAdd(strParam, "LifeTime", String(SystemMsgCurrent.LifeTime * 1000) );
		ParamAdd(strParam, "AnimationType", String(SystemMsgCurrent.AnimationType));
		ParamAdd(strParam, "Msg", MakeFullSystemMsg(SystemMsgCurrent.OnScrMsg,Schemestr));
		ParamAdd(strParam, "MsgColorR", String(SystemMsgCurrent.FontColor.R));
		ParamAdd(strParam, "MsgColorG", String(SystemMsgCurrent.FontColor.G));
		ParamAdd(strParam, "MsgColorB", String(SystemMsgCurrent.FontColor.B));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
		
		PlaySound(SystemMsgCurrent.Sound);
		c_handle.SetSelectedNum(LootingScheme);	 //������ ���� �ʴ´�.
	}
	
}

// function OnPartyLootingHasModified(String a_Param) //��Ƽ������ ����Ǿ�����
// {
// 	local int IsSuccess;
// 	local int LootingScheme;
// 	local string Schemestr;
// 	local string	strParam;
// 	
// 	//////////for ScreenMsg///////////
// 	local SystemMsgData SystemMsgCurrent;
// 	///////////////////////////////////////
// 
// 	//���� �޺��ڽ� ������ ����
// 	local PartyWnd script;
// 	local ComboBoxHandle c_handle;
// 	/////////////////////////
// 
// 	local TextBoxHandle t_handle;
// 
// 	
// 	NowLooting = false; //���ú���������
// 	RefreshLootingBox(); //���ѿ� ���� �޺��ڽ��� enable/disable �Ѵ�
// 
// 	script = PartyWnd(GetScript("PartyWnd"));
// 	c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
// 
// 	ParseInt(a_Param, "IsSuccess", IsSuccess);
// 	ParseInt(a_Param, "LootingScheme", LootingScheme);
// 	//�̰��� ��ũ���޽��� �ڵ� �߰�. �ɼ�â ��Ƽ���ù�� �޺��ڽ��� �ٷ�����
// 
// 	if(IsSuccess != 0) //�����̱⸸ �ϸ� partyMatchRoom �� ���ù���� ������ �ٲ���Ѵ�.
// 	{
// 		Schemestr = getLootingString(LootingScheme);
// 		t_handle = GetTextBoxHandle("PartyMatchRoomWnd.LootingMethod");
// 		t_handle.SetText(Schemestr);
// 	}
// 	
// 		
// 	if(script.AmILeader()) //�ڽ��� ��Ƽ�� Ȥ�� ��Ƽ�����̶��
// 	{
// 		AddSystemMessage(3136);
// 		if(IsSuccess != 0) //���� ���� 
// 		{
// 			debug("success now type is");
// 			debug(string(LootingScheme));
// 			SetOptionInt( "Game", "PartyLooting", LootingScheme ); //���常 �� ������� ���ü����� �����Ѵ�.(�ڱⰡ ������ �Ŵϱ�)
// //			Lootingtype = LootingScheme;
// 			//do not change. Preserve combobox's current Item.
// 		}
// 		else //������� �޺��ڽ� ������ ����
// 		{
// 			c_handle.SetSelectedNum(GetOptionInt( "Game", "PartyLooting"));			
// 		}
// 	}
// 	
// 
// 	if(IsSuccess == 0) //fail
// 	{
// 		//debug("��������");
// 	}
// 	else if(IsSuccess == 1)//success ��Ƽ���� ���, �޺��ڽ��� �ٲ��ְ� ������ �����ʴ´�
// 	{
// 		Schemestr = getLootingString(LootingScheme);
// 		GetSystemMsgInfo( 3138, SystemMsgCurrent);
// 		
// 		ParamAdd(strParam, "MsgType", String(1));
// 		ParamAdd(strParam, "WindowType", String(SystemMsgCurrent.WindowType));
// 		ParamAdd(strParam, "FontType", String(SystemMsgCurrent.FontType));
// 		ParamAdd(strParam, "BackgroundType", String(SystemMsgCurrent.BackgroundType));
// 		ParamAdd(strParam, "LifeTime", String(SystemMsgCurrent.LifeTime * 1000) );
// 		ParamAdd(strParam, "AnimationType", String(SystemMsgCurrent.AnimationType));
// 		ParamAdd(strParam, "Msg", MakeFullSystemMsg(SystemMsgCurrent.OnScrMsg,Schemestr));
// 		ParamAdd(strParam, "MsgColorR", String(SystemMsgCurrent.FontColor.R));
// 		ParamAdd(strParam, "MsgColorG", String(SystemMsgCurrent.FontColor.G));
// 		ParamAdd(strParam, "MsgColorB", String(SystemMsgCurrent.FontColor.B));
// 		ExecuteEvent(EV_ShowScreenMessage, strParam);
// 		
// 		PlaySound(SystemMsgCurrent.Sound);
// 		c_handle.SetSelectedNum(LootingScheme);	 //������ ���� �ʴ´�.
// 		
// 	}
// 	else if(IsSuccess == 2)//success �׳� ��ȿ� �ִ� ����� ���. �޺��ڽ��� �ٲ��ְ� ������ �����ʴ´�
// 	{
// 		Schemestr = getLootingString(LootingScheme);
// 		GetSystemMsgInfo( 3138, SystemMsgCurrent);
// 
// 		ParamAdd(strParam, "MsgType", String(1));
// 		ParamAdd(strParam, "WindowType", String(SystemMsgCurrent.WindowType));
// 		ParamAdd(strParam, "FontType", String(SystemMsgCurrent.FontType));
// 		ParamAdd(strParam, "BackgroundType", String(SystemMsgCurrent.BackgroundType));
// 		ParamAdd(strParam, "LifeTime", String(SystemMsgCurrent.LifeTime * 1000) );
// 		ParamAdd(strParam, "AnimationType", String(SystemMsgCurrent.AnimationType));
// 		ParamAdd(strParam, "Msg", MakeFullSystemMsg(SystemMsgCurrent.OnScrMsg,Schemestr));
// 		ParamAdd(strParam, "MsgColorR", String(SystemMsgCurrent.FontColor.R));
// 		ParamAdd(strParam, "MsgColorG", String(SystemMsgCurrent.FontColor.G));
// 		ParamAdd(strParam, "MsgColorB", String(SystemMsgCurrent.FontColor.B));
// 		ExecuteEvent(EV_ShowScreenMessage, strParam);
// 		
// 		PlaySound(SystemMsgCurrent.Sound);
// 		c_handle.SetSelectedNum(LootingScheme);	 //������ ���� �ʴ´�.
// 	}
// 	
// }

function OnAskPartyLootingModify(String a_Param)
{
	//Using for Party Looting Scheme Modification//
	local string LeaderName;
	local int LootingScheme;
	/////////////////////////////////////////////////
	local string Schemestr;

	// ���̾� �α� �ڽ����� ��, �ƴϿ� �� �������� �Ѵ�.
	dScript.SetButtonName( 184, 185 );
	
	DialogSetID( PARTY_MODIFY_REQUEST );
	DialogSetParamInt64( IntToInt64(10*1000) );			// 5 seconds
	DialogSetDefaultCancle(); // ���͸� ġ�ų� Ÿ�Ӿƿ��߻��� cancle�� �Ǵ�
	ParseString(a_Param, "LeaderName", LeaderName);
	ParseInt(a_Param, "LootingScheme", LootingScheme);
	Schemestr = getLootingString(LootingScheme);
	DialogShow(DIALOG_Modalless, DIALOG_Progress, MakeFullSystemMsg(GetSystemMessage(3134),Schemestr));
}
function HandleDialogOK() //��Ƽ���ú��� ����â 
{
	if( DialogIsMine() )
	{
		if( DialogGetID() == PARTY_MODIFY_REQUEST )
		{
			RequestPartyLootingModifyAgreement(1); //���� ��
		}
		else if( DialogGetID() == OPTION_CHANGE )
		{			
			SetUIState( "ShaderBuildState" );		
		}
	}
	
}

function HandleDialogCancel() //��Ƽ���ú��� ����â 
{
	// Ȯ��, ��� �� ���� 
	dScript.SetButtonName( 1337, 1342 );

	if( DialogIsMine() )
	{
		if( DialogGetID() == PARTY_MODIFY_REQUEST )
		{
			RequestPartyLootingModifyAgreement(0); //������ Ȥ�� Ÿ�Ӿƿ�
		}
	}
}

function OnComboBoxItemSelected( string sName, int index ) 
{
	local PartyWnd script;
	local ComboBoxHandle c_handle;
	
	// debug(string(bPartyMaster));
	// debug(string(IsRoomMaster()));
	// debug(string(bPartyMember));
	switch( sName )
	{
	case "LootingBox": 
		
		script = PartyWnd(GetScript("PartyWnd"));
		c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
		if(bPartyMaster || (IsRoomMaster() && !bPartyMember)) //��Ƽ�����ε� ��Ƽ���� �絵�ϴ� ��찡 �־
		{
			//���� ���ð� ������ �Ǽ����ϸ� ����. 
			//����� ������ ���� �����̶� ��ġ�ϴ� ������ ��Ƽ�� �ʴ��Ҷ� ����� ������ ����ϰ�, 
			//������ ����ǵ� ������ �����ϱ� �����̴�.
			if(GetOptionInt( "Game", "PartyLooting") == c_handle.GetSelectedNum()) 
				break;
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
			RequestPartyLootingModify(c_handle.GetSelectedNum()); // ���ú����� ��û�Ѵ�.
		}
		break;
	case "ResBox":
		ResetRefreshRate( ResolutionList[ index ].nWidth, ResolutionList[ index ].nHeight );
		break;
	
	case "DefaultPositionBox" :
		SetOptionInt( "Game", "LayoutDF", index );
		break;
	}
}

// 
// function OnComboBoxItemSelected( string sName, int index ) 
// {
// 	local PartyWnd script;
// 	local ComboBoxHandle c_handle;
// 	
// 	switch( sName )
// 	{
// 	case "LootingBox": 
// 		
// 		script = PartyWnd(GetScript("PartyWnd"));
// 		c_handle = GetComboBoxHandle("OptionWnd.LootingBox");
// 		if(script.AmILeader()) //�ڽ��� ��Ƽ�� Ȥ�� ��Ƽ�����̶��
// 		{
// 			//��Ƽ���� ������ �̶�� �÷��׸� �����Ѵ�.
// 			NowLooting = true;
// 			
// 			//���� ���ð� ������ �Ǽ����ϸ� ����. 
// 			//����� ������ ���� �����̶� ��ġ�ϴ� ������ ��Ƽ�� �ʴ��Ҷ� ����� ������ ����ϰ�, 
// 			//������ ����ǵ� ������ �����ϱ� �����̴�.
// 			if(GetOptionInt( "Game", "PartyLooting") == c_handle.GetSelectedNum()) 
// 				break;
// 			
// 			RefreshLootingBox(); //NowLooting�� true�� �����Ƿ� disable�ȴ�. ������ ����Ǹ� NowLooting�� Ǯ������
// 			RequestPartyLootingModify(c_handle.GetSelectedNum()); // ���ú����� ��û�Ѵ�.
// 
// 			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
// 		}
// 		else
// 		{
// 			//Lootingtype = c_handle.GetSelectedNum();
// 		}
// 		break;
// 	case "ResBox":
// 		ResetRefreshRate( ResolutionList[ index ].nWidth, ResolutionList[ index ].nHeight );
// 		break;
// 	
// 	case "DefaultPositionBox" :
// 		SetOptionInt( "Game", "LayoutDF", index );
// 		break;
// 	}
// }

////////////////////��Ƽ���� �ڵ� ����/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// �����̴� ��Ʈ�� �ڵ鷯 - lancelot 2006. 6. 13.
function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	local float fVolume;
	fVolume=GetVolumeFromSliderTick(iCurrentTick);
	switch(strID)
	{
	case "EffectVolumeSliderCtrl" :
		SetOptionFloat("Audio", "SoundVolume", fVolume);
		break;
	case "MusicVolumeSliderCtrl" :
		if(fVolume==0.0f)	// �����̴� �ٸ� �����̴� ���߿��� ������ ������ �ʰ� �ϱ� ���ؼ�
			fVolume=0.005f;
		SetOptionFloat("Audio", "MusicVolume", fVolume);
		break;
	case "SystemVolumeSliderCtrl" :
		SetOptionFloat("Audio", "WavVoiceVolume", fVolume);
		break;
	case "TutorialVolumeSliderCtrl" :
		SetOptionFloat("Audio", "OggVoiceVolume", fVolume);
		break;
	}
}

function OnDefaultPosition()
{
	GetCurrentResolution(g_CurrentMaxWidth, g_CurrentMaxHeight);
	//~ TargetStatusWnd.SetStuckable(false);
	//~ StatusWnd.SetStuckable(false);
	//~ SystemMenuWnd.SetStuckable(false);
	if (GetOptionInt( "Game", "LayoutDF" ) == 1)
	{
		//branch
		//StatusWnd.HideWindow();
		//end of branch
		if (TargetStatusWnd.IsShowWindow())
		{	
			bg_Temp = true;
			TargetStatusWnd.HideWindow();
		}
		else
		{
			bg_Temp = false;
		}
		class'UIAPI_WINDOW'.static.SetUITimer("OptionWnd", 1, 200);
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetUITimer("OptionWnd", 2, 200);
	}
	
}

function SetStuck(bool a)
{
	//~ local WindowHandle TargetStatusWnd;
	//~ local WindowHandle StatusWnd;
	//~ local WindowHandle SystemMenuWnd;
	//~ TargetStatusWnd = GetHandle( "TargetStatusWnd" );
	//~ StatusWnd = GetHandle( "StatusWnd" );
	//~ SystemMenuWnd = GetHandle( "SystemMenuWnd" );
	
	//~ if (a)
	//~ {
		//~ TargetStatusWnd.SetStuckable(false);
		//~ StatusWnd.SetStuckable(false);
		//~ SystemMenuWnd.SetStuckable(false);
	//~ }
	//~ else if (!a)
	//~ {
		//~ TargetStatusWnd.SetStuckable(true);
		//~ StatusWnd.SetStuckable(true);
		//~ SystemMenuWnd.SetStuckable(true);
	//~ }
}


function OnTimer(int TimerID)
{
	if (TimerID==1)	
	{
		class'UIAPI_WINDOW'.static.KillUITimer("OptionWnd", 1 );
		//branch : �� �Ʒ��� �ٸ���... TTP 33257
		//StatusWnd.ShowWindow();
		//end of branch
		StatusWnd.MoveTo(g_CurrentMaxWidth-170, g_CurrentMaxHeight-170);
		TargetStatusWnd.MoveTo(347,g_CurrentMaxHeight-184);
		if (bg_Temp)
			TargetStatusWnd.ShowWindow();

		SystemMenuWnd.SetAnchor("StatusWnd","TopRight", "BottomRight", -12, 0);
		SystemMenuWnd.ClearAnchor();
	}
	if (TimerID==2)	
	{
		class'UIAPI_WINDOW'.static.KillUITimer("OptionWnd", 2 );
		StatusWnd.MoveTo(0, 0);
		TargetStatusWnd.MoveTo((g_CurrentMaxWidth/2)-85, 0);
		if (bg_Temp)
			TargetStatusWnd.ShowWindow();
		
		SystemMenuWnd.SetAnchor("MenuWnd","TopRight", "BottomRight", -2, 0);
		SystemMenuWnd.ClearAnchor();
	}
	//~ TargetStatusWnd.SetStuckable(true);
	//~ StatusWnd.SetStuckable(true);
	//~ SystemMenuWnd.SetStuckable(true);
}


function SetTutorialData(bool bOption)
{
}




//=================================================================================
// function : LoadVideoOption()
//
// Description :
//	* Reads option.ini file, and apply video options.
//	* There is no need to apply options here for the options that share key between
//	  script and native code. (e.g. Video.Gamma)
//	* On the other hand, options that do not share key between script and native code
//	  MUST be applied here. (e.g. Video.L2Shader)
//	* This function MUST be called when loading the game. Otherwise, some of the
//	  options in option.ini will not be applied to the game.
//
// Revision History
//	* 2007/11/16 NeverDie: Created
//---------------------------------------------------------------------------------
function LoadVideoOption()
{
	local bool bKeepMinFrameRate;		// Min frame rate
	local bool bL2Shader;				// Shader 3.0
	local bool bShaderDOF;				// Shader 3.0 Depth of field
	local bool bShaderWater;			// Shader 3.0 Water
	local bool bShaderShadow;			// Shader 3.0 Self shadow

	// Shader option should be set only when "KeepMinFrameRate" option is off
	bKeepMinFrameRate = GetOptionBool( "Video", "IsKeepMinFrameRate" );
	if( !bKeepMinFrameRate )
	{
		// If current driver doesn't support Shader 3.0, there is no need to set Shader 3.0 options
		if( nPixelShaderVersion >= 30 && nVertexShaderVersion >= 30 )
		{
			// Apply Shader 3.0 config
			bL2Shader = GetOptionBool( "Video", "L2Shader" );			
			SetL2Shader(bL2Shader);

			// DOF, WaterEffect, Shadow depend on L2Shader option. Set them only when bL2Shader is on.
			if( bL2Shader )
			{
				// Apply Shader 3.0 Depth of Field
				bShaderDOF = GetOptionBool( "Video", "S30DOFBOX" );
				SetDOF(bShaderDOF);
					
				// Apply Shader 3.0 Water
				bShaderWater = GetOptionBool( "Video", "S30WaterEffectBox" );
				SetShaderWaterEffect(bShaderWater);
				
				// Apply Shader 3.0 Self shadow
				bShaderShadow = GetOptionBool( "Video", "S30ShadowBox" );
				SetDepthBufferShadow(bShaderShadow);
			}
		}
	}
}

//=================================================================================
// function : LoadAudioOption()
//
// Description :
//	* Reads option.ini file, and apply audio options.
//	* There is no need to apply options here for the options that share key between
//	  script and native code. (e.g. Video.Gamma)
//	* On the other hand, options that do not share key between script and native code
//	  MUST be applied here. (e.g. Video.L2Shader)
//	* This function MUST be called when loading the game. Otherwise, some of the
//	  options in option.ini will not be applied to the game.
//
// Revision History
//	* 2007/11/16 NeverDie: Created
//---------------------------------------------------------------------------------
function LoadAudioOption()
{
	local bool bMute;		// Audio mute

	// If device does not support audio, it's ok to simply ignore audio options
	if( CanUseAudio() )
	{
		// We only need to apply "Mute" option, because keys for volumes are shared between script and native code.
		bMute = GetOptionBool( "Audio", "AudioMuteOn" );
		if(bMute)
		{
			// Turn off all sounds
			SetSoundVolume( 0.f );
			SetMusicVolume( 0.f );
			SetWavVoiceVolume( 0.f );
			SetOggVoiceVolume( 0.f );
		}
	}
}

//=================================================================================
// function : LoadGameOption()
//
// Description :
//	* Reads option.ini file, and apply game options.
//	* There is no need to apply options here for the options that share key between
//	  script and native code. (e.g. Video.Gamma)
//	* On the other hand, options that do not share key between script and native code
//	  MUST be applied here. (e.g. Video.L2Shader)
//	* This function MUST be called when loading the game. Otherwise, some of the
//	  options in option.ini will not be applied to the game.
//
// Revision History
//	* 2007/11/16 NeverDie: Created
//---------------------------------------------------------------------------------
function LoadGameOption()
{
	// Currently there is no options to load for the game tab.

	local bool bChecked;
	bChecked=false;
	bChecked=GetOptionBool( "Game", "RightClickBox");
	SetFixedDefaultCamera(bChecked);
}
defaultproperties
{
}
