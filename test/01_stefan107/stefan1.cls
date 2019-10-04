%% This is file `stefan1.cls'.
%%
%% LaTeX 2e driver class file for STEFAN1 project.
%%
%% Macros written by VTeX Ltd., Lithuania for De Gruyter
%% Please submit bugs or your comments to latex-support@vtex.lt
%%
%% You are free to use this class file as you see fit, provided
%% that you do not make changes to the file.
%% If you DO make changes, you are required to rename this file.
%%
%% It may be distributed under the terms of the LaTeX Project Public
%% License, as described in lppl.txt in the base LaTeX distribution.
%% Either version 1.3 or, at your option, any later version.
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{stefan1}
    [2018/05/23, v0.0.2 De Gruyter book class]
\def\fmt@name{stefan1}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{dgbook}}
\PassOptionsToPackage{numbers}{vtexnatbib}
\ProcessOptions*

\RequirePackage{etoolbox}
\csdef{load@\fmt@name @settings}{%
  \let\book@code\fmt@name % for book-aux-toc
  \let\@vtexproject\fmt@name % for pdfwf-settings
  \gdef\@xeisbnpdf{9783110492132}%
  \cipfalse
  \global\@twocolumnfalse
  \global\@monographytrue
  \gdef\dg@book@layout{1}% 1 -- 17x24 cm
  \gdef\@publisherlogo{dice}%
  \gdef\bookstart@date@info{20180319}%
  \gdef\app@num##1{\Alph{##1}}% appendix numeration -- either \Alph or \Roman
  }

\LoadClass{dgbook}

\def\book@editors@postfix{ (Eds.)}

\let\monography@abstract@afterskip\keywords@afterskip
\endinput
%%
%% End of file `stefan1.cls'.
