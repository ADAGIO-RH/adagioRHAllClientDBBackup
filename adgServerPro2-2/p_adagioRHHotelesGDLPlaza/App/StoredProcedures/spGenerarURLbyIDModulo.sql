USE [p_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spGenerarURLbyIDModulo]
(
	@IDModulo int = 0
)
AS
BEGIN

Select M.IDArea,A.Descripcion as Area,
	   M.IDModulo,
	   M.Descripcion as Modulo,
	   A.PrefijoURL,
	   --(max(RIGHT(IDUrl, LEN(A.PrefijoURL))) + 1 )AS maxURL,
	   concat(A.PrefijoURL,(max(RIGHT(IDUrl, LEN(A.PrefijoURL))) + 1 )) AS siguienteUrl   
	from App.tblCatModulos M
		Inner join App.tblCatAreas A
			on M.IDArea = A.IDArea
		left join App.tblCatUrls U on M.IDModulo = U.IDModulo
	Where (M.IDModulo = @IDModulo) OR (@IDModulo = 0)
	GROUP BY
	M.IDArea,
	A.Descripcion,
	M.IDModulo,
	M.Descripcion,
	A.PrefijoURL
	
END
GO
