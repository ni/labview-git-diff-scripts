<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="20008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="Screenshots" Type="Folder" URL="../Screenshots">
			<Property Name="NI.DISK" Type="Bool">true</Property>
		</Item>
		<Item Name="Utilities" Type="Folder" URL="../Utilities">
			<Property Name="NI.DISK" Type="Bool">true</Property>
		</Item>
		<Item Name="Compare.vi" Type="VI" URL="../Compare.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="Get File Extension.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Get File Extension.vi"/>
				<Item Name="Get LV Class Default Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/LVClass/Get LV Class Default Value.vi"/>
				<Item Name="Is Path and Not Empty.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Is Path and Not Empty.vi"/>
				<Item Name="NI_FileType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/lvfile.llb/NI_FileType.lvlib"/>
				<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
				<Item Name="NI_XML.lvlib" Type="Library" URL="/&lt;vilib&gt;/xml/NI_XML.lvlib"/>
			</Item>
			<Item Name="DOMUserDefRef.dll" Type="Document" URL="DOMUserDefRef.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="kernel32.dll" Type="Document" URL="kernel32.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="Assembly" Type=".NET Interop Assembly">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{D32CAFC5-461B-409D-BF2F-23B109AD3746}</Property>
				<Property Name="App_INI_GUID" Type="Str">{AD9C6719-A934-4469-8EC1-DBE77943ED8E}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_autoIncrement" Type="Bool">true</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{7190EA51-BB2E-4F7D-886B-13567E383F16}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">Assembly</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/NI_AB_PROJECTNAME/Assembly</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{96DBD00E-4BEF-4343-A786-990E5DA1C286}</Property>
				<Property Name="Bld_version.build" Type="Int">6</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">CgCompare.dll</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/NI_AB_PROJECTNAME/Assembly/CgCompare.dll</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/NI_AB_PROJECTNAME/Assembly/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="DotNET2011CompatibilityMode" Type="Bool">false</Property>
				<Property Name="DotNETAssembly_ClassName" Type="Str">Compare</Property>
				<Property Name="DotNETAssembly_delayOSMsg" Type="Bool">true</Property>
				<Property Name="DotNETAssembly_Namespace" Type="Str">Cg</Property>
				<Property Name="DotNETAssembly_signAssembly" Type="Bool">false</Property>
				<Property Name="DotNETAssembly_StrongNameKeyFileItemID" Type="Ref"></Property>
				<Property Name="DotNETAssembly_StrongNameKeyGUID" Type="Str">{6E59D27C-458D-439F-8569-23B8710142D1}</Property>
				<Property Name="Source[0].itemID" Type="Str">{93D5B064-27CD-4F8A-9DC9-16DBFF0FDF5F}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/Utilities/ParseArguments.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/Utilities/CheckPaths.vi</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[2].type" Type="Str">VI</Property>
				<Property Name="Source[3].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[0]VIProtoConNum" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[0]VIProtoDataType" Type="Str">I32</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[0]VIProtoIutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[0]VIProtoName" Type="Str">returnvalue</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[1]VIProtoConNum" Type="Int">11</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[1]VIProtoDataType" Type="Str">String</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[1]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[1]VIProtoIutputIdx" Type="Int">11</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[1]VIProtoName" Type="Str">oldVIPath</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[2]VIProtoConNum" Type="Int">10</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[2]VIProtoDataType" Type="Str">String</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[2]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[2]VIProtoIutputIdx" Type="Int">10</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[2]VIProtoName" Type="Str">newVIPath</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[2]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[3]VIProtoConNum" Type="Int">9</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[3]VIProtoDataType" Type="Str">String</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[3]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[3]VIProtoIutputIdx" Type="Int">9</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[3]VIProtoName" Type="Str">outputDirectory</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[3]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[4]VIProtoConNum" Type="Int">3</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[4]VIProtoDataType" Type="Str">String</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[4]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[4]VIProtoIutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[4]VIProtoName" Type="Str">resultsDirectory</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[4]VIProtoOutputIdx" Type="Int">3</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[5]VIProtoConNum" Type="Int">2</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[5]VIProtoDataType" Type="Str">String</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[5]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[5]VIProtoIutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[5]VIProtoName" Type="Str">description</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[5]VIProtoOutputIdx" Type="Int">2</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[6]VIProtoConNum" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[6]VIProtoDataType" Type="Str">String</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[6]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[6]VIProtoIutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[6]VIProtoName" Type="Str">errorMessage</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[6]VIProtoOutputIdx" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[7]VIProtoConNum" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[7]VIProtoDataType" Type="Str">I32</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[7]VIProtoDir" Type="Int">4</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[7]VIProtoIutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[7]VIProtoName" Type="Str">Error__32Code</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[7]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]MethodName" Type="Str">Compare</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIName" Type="Str">Compare.vi</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIProtoConNum" Type="Int">8</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIProtoDataType" Type="Str">Cluster</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIProtoDir" Type="Int">6</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIProtoIutputIdx" Type="Int">8</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIProtoName" Type="Str">error__32in</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfo[8]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfoVIDocumentation" Type="Str"></Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfoVIDocumentationEnabled" Type="Int">0</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfoVIIsNamesSanitized" Type="Int">1</Property>
				<Property Name="Source[3].ExportedAssemblyVI.VIProtoInfoVIProtoItemCount" Type="Int">9</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/Compare.vi</Property>
				<Property Name="Source[3].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[3].type" Type="Str">ExportedAssemblyVI</Property>
				<Property Name="Source[4].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[4].itemID" Type="Ref"></Property>
				<Property Name="Source[4].Library.allowMissingMembers" Type="Bool">true</Property>
				<Property Name="Source[4].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[4].type" Type="Str">Library</Property>
				<Property Name="SourceCount" Type="Int">5</Property>
				<Property Name="TgtF_companyName" Type="Str">National Instruments</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Assembly</Property>
				<Property Name="TgtF_internalName" Type="Str">Assembly</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2020 National Instruments</Property>
				<Property Name="TgtF_productName" Type="Str">Assembly</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{82CA601F-7580-4298-BE66-2694EF937693}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">CgCompare.dll</Property>
			</Item>
		</Item>
	</Item>
</Project>
