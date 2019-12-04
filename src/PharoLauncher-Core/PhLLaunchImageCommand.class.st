"
Launch the selected image with the appropriate virtual machine.
"
Class {
	#name : #PhLLaunchImageCommand,
	#superclass : #PhLImageCommand,
	#instVars : [
		'useSettings'
	],
	#classVars : [
		'QuitOnLaunch',
		'WarnOnArchMismatch'
	],
	#category : #'PharoLauncher-Core-Commands'
}

{ #category : #settings }
PhLLaunchImageCommand class >> archMismatchSettingDescription [
	^ 'Get a warning when trying to launch an image with a different architecture than the Launcher (i.e. trying to launch a 32-bit image from Pharo Launcher 64-bit). '
]

{ #category : #settings }
PhLLaunchImageCommand class >> archMismatchSettingLabel [
	^ 'Warn on image architecture mismatch? ' translated
]

{ #category : #settings }
PhLLaunchImageCommand class >> quitOnLaunch [
	^ QuitOnLaunch ifNil: [  QuitOnLaunch := false ].
]

{ #category : #settings }
PhLLaunchImageCommand class >> quitOnLaunch: aBoolean [
	QuitOnLaunch = aBoolean 
		ifFalse: [ QuitOnLaunch := aBoolean ]
]

{ #category : #settings }
PhLLaunchImageCommand class >> settingsOn: aBuilder [
	<systemsettings>
	<pharoLauncherSettings>
	(aBuilder setting: #quitOnLaunch)
		label: 'Quit On Launch' translated;
		parent: #pharoLauncher;
		target: self;
		order: 30;
		description:
			'When enabled, Launcher quits when an image is launched. ' , String cr
				, 'When disabled, Launcher stays alive when an image is launched.'.
	(aBuilder setting: #warnOnArchMismatch)
		label: self archMismatchSettingLabel;
		parent: #pharoLauncher;
		target: self;
		order: 35;
		description: self archMismatchSettingDescription
]

{ #category : #settings }
PhLLaunchImageCommand class >> warnOnArchMismatch [
	^ WarnOnArchMismatch ifNil: [  WarnOnArchMismatch := true ].
]

{ #category : #settings }
PhLLaunchImageCommand class >> warnOnArchMismatch: aBoolean [
	WarnOnArchMismatch := aBoolean.

]

{ #category : #converting }
PhLLaunchImageCommand >> asSpecCommand [
	^ super asSpecCommand
		iconName: #smallDoItIcon;
		shortcutKey: $l meta;
		beDisabledWhenCantBeRun;
		yourself
]

{ #category : #converting }
PhLLaunchImageCommand >> asSpecLaunchWithoutSettingsCommand [
	self
		doNotUseSettings;
		name: 'Basic launch';
		description: 'Launch the selected Pharo image without settings'.
	^ super asSpecCommand
		iconProvider: self;
		iconName: #smallDoItIcon;
		"shortcutKey: $l meta, $b meta ;"
			beDisabledWhenCantBeRun;
		yourself
]

{ #category : #configuring }
PhLLaunchImageCommand >> doNotUseSettings [
	useSettings := false.
]

{ #category : #executing }
PhLLaunchImageCommand >> execute [
	self imagesPresenter hasSingleImageSelected
		ifTrue: [ self launchSelectedImage ]
]

{ #category : #private }
PhLLaunchImageCommand >> iconNamed: aName [
	"Only used for basic launch command"
	^ (super iconNamed: aName) asGrayScaleWithAlpha
]

{ #category : #initialization }
PhLLaunchImageCommand >> initialize [
	super initialize.
	useSettings := true.
	self name: 'Launch'
]

{ #category : #executing }
PhLLaunchImageCommand >> launchImage: aPhLImage [
	[ | launchConfig |
	launchConfig := aPhLImage defaultLaunchConfiguration.
	useSettings ifFalse: [ launchConfig doNotUseSettings ].
	aPhLImage launch. ]
		on: PhLError
		do: [ :error | error uiAlert ].
	self class quitOnLaunch
		ifTrue: [ self quit ]
]

{ #category : #executing }
PhLLaunchImageCommand >> launchSelectedImage [
	self launchImage: self imagesPresenter singleImage
]

{ #category : #private }
PhLLaunchImageCommand >> quit [
	(PhLQuitCommand forSpec context: self imagesPresenter) execute
]