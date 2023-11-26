USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spBuscarCurriculumDigitalCandidatooWithBinaries]
(
	@IDCandidato int = 0
)
AS
BEGIN
SELECT [IDCurriculumDigitalCandidato]
      ,[IDCandidato]
      ,[Name]
      ,[ContentType]
      ,[Data]
	  ,ROW_NUMBER()over(ORDER BY [IDCurriculumDigitalCandidato])as ROWNUMBER
  FROM [Reclutamiento].[tblCurriculumDigitalCandidato]
  WHERE 
		 ([IDCandidato]= @IDCandidato OR isnull(@IDCandidato,0) = 0)

		

END
GO
