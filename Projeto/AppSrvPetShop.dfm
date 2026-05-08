object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Servi'#231'o de Integra'#231#227'o PetShop'
  ClientHeight = 121
  ClientWidth = 299
  Color = clBtnFace
  Constraints.MaxHeight = 160
  Constraints.MaxWidth = 315
  Constraints.MinHeight = 160
  Constraints.MinWidth = 315
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  object lblPorta: TLabel
    Left = 80
    Top = 32
    Width = 31
    Height = 15
    Caption = 'Porta:'
  end
  object btnStart: TButton
    Left = 56
    Top = 80
    Width = 75
    Height = 25
    Caption = '&Start'
    TabOrder = 1
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 176
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Sto&p'
    TabOrder = 2
    OnClick = btnStopClick
  end
  object spePorta: TSpinEdit
    Left = 128
    Top = 29
    Width = 81
    Height = 24
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 9000
  end
end
