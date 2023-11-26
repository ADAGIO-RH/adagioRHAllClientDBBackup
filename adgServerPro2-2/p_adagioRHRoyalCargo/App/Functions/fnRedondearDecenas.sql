USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION App.fnRedondearDecenas
(
	@Valor int
)
RETURNS int
AS
BEGIN
	 
	-- Return the result of the function
	RETURN @Valor + 
			CASE CONVERT(INT, @Valor)%10 WHEN 0 THEN 0 ELSE (10-(CONVERT(INT, @Valor)%10)) END

END
GO
