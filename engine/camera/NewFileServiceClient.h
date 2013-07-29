/*
* Copyright (c) 2002-2004 Nokia Corporation and/or its subsidiary(-ies).
* All rights reserved.
* This component and the accompanying materials are made available
* under the terms of "Eclipse Public License v1.0"
* which accompanies this distribution, and is available
* at the URL "http://www.eclipse.org/legal/epl-v10.html".
*
* Initial Contributors:
* Nokia Corporation - initial contribution.
*
* Contributors:
*
* Description:  Client side API
*
*/



#ifndef NEWFILESERVICECLIENT_H
#define NEWFILESERVICECLIENT_H

//  INCLUDES
#include <NewFileService.hrh>
#include <e32std.h>
#include <badesca.h>
#include <AknServerApp.h>

// FORWARD DECLARATIONS
class RFile;
class CApaServerAppExitMonitor;
class CNewFileServiceClient;
class CAiwGenericParamList;

// CLASS DECLARATION


class NewFileServiceFactory
	{
	public:
		IMPORT_C static CNewFileServiceClient* NewClientL();
	};

/**
*  Client side API for New File Service
*
*  @lib NewService.lib
*  @since Series 60 3.0
*/
class CNewFileServiceClient : public CBase
    {

    public: // New functions

        /**
        * Create new media file
        * @since Series 60 3.0
        * @param aApplicationUid Uid for the server application
        * @param aFileNames Array for the created media files
        * @param aParams Parameters for the operation
        * @param aFileType Type of media file requested
        * @param aMultipleFiles Multiple files can be created
        * @return ETrue if new file was succesfully created
        */        
		virtual TBool NewFileL( CDesCArray& aFileNames,
							   CAiwGenericParamList* aParams,
							   TNewServiceFileType aFileType,
							   TBool aMultipleFiles ) = 0;
		virtual TBool NewFileL( TUid aApplicationUid,
							   CDesCArray& aFileNames,
							   	CAiwGenericParamList* aParams,
							   TNewServiceFileType aFileType,
							   TBool aMultipleFiles ) = 0;


		/**
        * NOTE: When you pass file handles to new file service,
        * the handle should be opened using ShareProtected()
        * file session, otherwise handles can't be transfered through
        * client-server interface.
        */
        
        /**
        * Create new media file
        * @since Series 60 3.0
        * @param aApplicationUid Uid for the server application
        * @param aFile File handle for the media file
        * @param aParams Parameters for the operation        
        * @param aFileType Type of media file requested
        * @return ETrue if new file was succesfully created
        */                
		virtual TBool NewFileL( RFile& aFileHandle,
							   CAiwGenericParamList* aParams,
							   TNewServiceFileType aFileType ) = 0;

		virtual TBool NewFileL( TUid aApplicationUid,
							   RFile& aFileHandle,
							   CAiwGenericParamList* aParams,
							   TNewServiceFileType aFileType ) = 0;



    };

#endif      // NEWFILESERVICECLIENT_H

// End of File
