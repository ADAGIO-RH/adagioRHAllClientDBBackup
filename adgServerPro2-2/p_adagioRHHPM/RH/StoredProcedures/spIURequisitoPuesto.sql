USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIURequisitoPuesto](
	@IDRequisitoPuesto int = 0,
	@IDPuesto int,
	@IDTipoCaracteristica int, 
	@Requisito varchar(max),
	@Activo bit,
	@TipoValor varchar(255),
	@ValorEsperado varchar(max),
	@IDUsuario int
) as

	set @Requisito = UPPER(@Requisito)
	if (ISNULL(@IDRequisitoPuesto, 0) = 0)
	begin
		insert RH.tblRequisitosPuestos(IDPuesto, IDTipoCaracteristica, Requisito, Activo, TipoValor, ValorEsperado)
		values(@IDPuesto, @IDTipoCaracteristica, @Requisito, @Activo, @TipoValor, @ValorEsperado)
	end else
	begin
		update RH.tblRequisitosPuestos
			set
				Requisito = @Requisito,
				Activo = @Activo,
				TipoValor = @TipoValor,
				ValorEsperado = @ValorEsperado
		where IDRequisitoPuesto = @IDRequisitoPuesto
	end
GO
