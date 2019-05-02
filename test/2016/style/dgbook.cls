%% This is file `dgbook.cls'.
%%
%% LaTeX 2e class file for books published by De Gruyter.
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
\ProvidesClass{dgbook}
    [2018/03/29, v0.1.90 De Gruyter book class]
\def\dg@fmt@name{dgbook}

%% Latex warnings write only to log file.
\protected\def\GenericWarning#1#2{%
   \begingroup
      \def\MessageBreak{^^J#1}%
      \set@display@protect
      \wlog{^^J#2\on@line.^^J}%
   \endgroup
}

\RequirePackage{ifpdf}
\ifpdf
  \RequirePackage{pdfwf-settings}
  \RequirePackage{pdfwf-outputpage}
  \RequirePackage{pdfwf-graphics}
\else
  \RequirePackage{vtexgraphicx}
  \RequirePackage{degruyterpi}
  \RequirePackage{pagecrop}
  \AtBeginDocument{%
    \special{vtex:settings.vtexprod.dvips={xdvipsk}}%
    }
\fi
\@ifundefined{wwwfalse}{\newif\ifwww}{}

\RequirePackage{htpicture}
\RequirePackage{htmisc}

\def\@vtexpublisher{dgbook}% for pdfwf-settings

\newif\if@restonecol \@restonecolfalse

\DeclareOption{onecolumn}{\@twocolumnfalse\@restonecoltrue}
\DeclareOption{twocolumn}{\@twocolumntrue}
\DeclareOption{leqno}{\input{leqno.clo}}
\DeclareOption{fleqn}{\input{fleqn.clo}}%
\newif\if@rotating@loaded \@rotating@loadedfalse
\DeclareOption{rotating}{%
  \@rotating@loadedtrue
  \AtEndOfClass{\RequirePackage[dvips,counterclockwise,figuresright]{rotating}}%
  }
\DeclareOption{crcready}{%
  \AtBeginDocument{%
    \gdef\rtitleheadline{}%
    \gdef\@copyright{}%
    \pagestyle{empty}
    \relax
    }%
  }
\newif\if@pdfdraft
\DeclareOption{pdfdraft}{%
  \global\@pdfdrafttrue
  }
\AtBeginDocument{%
  \if@pdfdraft
    \hypersetup{%
    colorlinks=true,
    linkcolor=blue,
    citecolor=blue,
    pagecolor=blue,
    urlcolor=blue}%
  \fi
  }%

\PassOptionsToPackage{ngerman,english}{babel}
\AtEndOfClass{\main@language{english}}
\DeclareOption{ngerman}{%
  \AtEndOfClass{\main@language{ngerman}}%
  }
\DeclareOption{english}{%
  \AtEndOfClass{\main@language{english}}%
  }

%% Numbering switches:
\newif\if@seceqn   \@seceqnfalse   \DeclareOption{seceqn}{\@seceqntrue}
\newif\if@secfloat \@secfloatfalse \DeclareOption{secfloat}{\@secfloattrue}
\newif\if@secthm                   \DeclareOption{secthm}{\@secthmtrue}

\DeclareOption{p1}{\def\load@prelims{1}}
\DeclareOption{p2}{\def\load@prelims{1}}
\DeclareOption{p3}{\def\load@prelims{1}}

\newif\if@addressblockoutput \@addressblockoutputtrue
\DeclareOption{noaddressblock}{\@addressblockoutputfalse}

\newif\if@monography
\newif\ifcip\ciptrue% CIP or PCN; in latter case \PCN should be defined

\def\bib@style{0}
\DeclareOption{vancouver}{\def\bib@style{1}\def\bib@style@name{spr-vancouver}}

%% Books
\DeclareOption{werling}{%
  \gdef\book@code{werling}% for book-aux-toc
  \gdef\@vtexproject{werling}% for pdfwf-settings
  \gdef\@xeisbnpdf{9783110531923}%
  \gdef\@booktitle{Optimale aktive Fahreingriffe}%
  \global\@twocolumnfalse
  \global\@monographytrue
  \gdef\dg@book@layout{1}%
  \gdef\@publisherlogo{dg-degruyter}%
  \gdef\use@werling@math{\RequirePackage{degruyter-fonts}}%
  \gdef\bookstart@date@info{20170410}%
  \PassOptionsToPackage{numbers}{vtexnatbib}%
  }
\DeclareOption{fine}{%
  \gdef\book@code{fine}% for book-aux-toc
  \gdef\@vtexproject{fine}% for pdfwf-settings
  \gdef\@xeisbnpdf{9783110516142}%
  \gdef\@booktitle{Highlights in Algebra and Number Theory}%
  \global\@twocolumnfalse
  \global\@monographytrue
  \gdef\dg@book@layout{1}%
  \gdef\@publisherlogo{dg-degruyter}%
  \gdef\pageIII@fixed@false{1}%
  \gdef\bookstart@date@info{20170510}%
  \PassOptionsToPackage{numbers}{vtexnatbib}%
  }
\DeclareOption{west}{%
  \gdef\book@code{west}% for book-aux-toc
  \gdef\@vtexproject{west}% for pdfwf-settings
  \gdef\@xeisbnpdf{9783110535136}%
  \gdef\@booktitle{Nature’s Patterns and the Fractional Calculus}%
  \global\@twocolumnfalse
  \global\@monographytrue
  \gdef\dg@book@layout{1}%
  \gdef\@publisherlogo{dg-degruyter}%
  \gdef\bookstart@date@info{20170512}%
  \PassOptionsToPackage{numbers}{vtexnatbib}%
  }

\gdef\app@num#1{\Roman{#1}}% default appendix numeration

\ifdefined\fmt@name
  \csuse{load@\fmt@name @settings}
\fi

%% class versions for users
\def\dg@version{100}% initial version

\ProcessOptions*

\RequirePackage{fileinfo}
\getFileInfo

\if@twocolumn
  \PassOptionsToClass{twocolumn}{book}
\fi

\newdimen\dg@vgrid
\dg@vgrid=6.5bp
\ifcase\dg@book@layout
\or
  \PassOptionsToPackage{medium}{dgruyterx-book}
\fi

\LoadClass{book}
\RequirePackage{etoolbox}
\RequirePackage[listfiles,silent]{vtex-ltxext} % mandatory package
\RequirePackage{printead}
\def\ead@href#1#2{\href{#1}{#2}}%

\gdef\@id@line{\hfill}
\gdef\@id@dim@@{\hfill}

%% >>> Global book definitions >>>
\newcounter{schapter}
\setcounter{chapter}{0}
\setcounter{schapter}{0}
\newcommand\thisischapter[1]{%
  \setcounter{chapter}{#1}%
  \addtocounter{chapter}{-1}%
  }
\newcommand\thisispart[1]{%
  \setcounter{part}{#1}%
  \addtocounter{part}{-1}%
  }
\gdef\dg@doibase{https://doi.org/}
\gdef\dg@doiprefix{10.1515}
\gdef\book@DOI{\dg@doiprefix/\@xeisbnpdf}
\ifnum\bookstart@date@info>20170705\relax
  \def\@DOI@fmt{%
    \ifx\@DOI\@empty
    \else
      \href{\dg@doibase\@DOI}{\dg@doibase\@DOI}%
    \fi
    }
\else
  \def\@DOI@fmt{%
    \ifx\@DOI\@empty
    \else
      DOI \@DOI
    \fi
    }
\fi
\newcounter{pseudochapter}
\def\bookbackmatter{%
  \gdef\@bookbackmatter{1}%
  \gdef\book@part@type{bookbackmatter}%
  }
\def\lastchapternumber#1{%
  \bookbackmatter
  \setcounter{pseudochapter}{#1}%
  }
%% <<< Global book definitions <<<

\ifnum\jobstart@date@info>20171204\relax
  \RequirePackage{textcomp}
  \RequirePackage[intlimits,tbtags]{amsmath}
  \RequirePackage{amsfonts}
\fi

\ifdefined\HCode
  \RequirePackage{luatexbase}
  \RequirePackage{luacode}
  \begin{luacode*}
    local fontspec = require "dg-fontspec-4ht"
    luatexbase.add_to_callback("pre_linebreak_filter", fontspec.char_to_entity, "Char to entity")
    luatexbase.add_to_callback("hpack_filter", fontspec.char_to_entity, "hpack-char-to-entity")
    luatexbase.add_to_callback("mlist_to_hlist", fontspec.char_to_entity_in_mlist, "Char to entity in mlist")
  \end{luacode*}
  \ifnum\jobstart@date@info<20180101\relax
    \def\nofix@int{true}
  \fi
\else
  \ifnum\jobstart@date@info>20171204\relax
      \RequirePackage{degruyter-minion-ps-fonts}
  \else
      \RequirePackage[no-math,quiet]{fontspec}%(only for the luatex or the xetex engine)
  \fi
\fi

\def\nohyphen{%
  \pretolerance=10000
  \tolerance=10000
  \hyphenpenalty=10000
  \exhyphenpenalty=10000
  }

\def\DGAPPROVAL{%
  \RequirePackage{dg-approval}%
  \hide@line@numbers
  \check@lpagefalse
  }

\def\define@english@refname{%
  \ifcsname\fmt@name @refname\endcsname % possibility to define refname in class file
    \csletcs{refname}{\fmt@name @refname}%
  \else
    \ifnum\bookstart@date@info>20170723\relax
      \def\refname{Bibliography}%
    \fi
  \fi
  }

\RequirePackage{vtexnatbib}
\ifNAT@numbers
  \renewcommand\NAT@open{\textup{[}}%
  \renewcommand\NAT@close{\textup{]}}%
  \renewcommand\NAT@sep{\textup{,}}%
  \def\vtex@cite@dbg#1{\textup{#1}}%
\else
  \renewcommand\NAT@text@sep{\textup{,}}%
\fi
\def\citenumfont#1{\textup{#1}}

%% >>> Math settings >>>
\if@seceqn
  \@addtoreset{equation}{section}
  \renewcommand\theequation{\thesection.\@arabic\c@equation}
\fi
\def\eqncr{\\}

\ifnum\bookstart@date@info>20170926\relax
  \newdimen\eqnarraycolsep
  \setlength\eqnarraycolsep{1.2pt}%
\fi
\ifdefined\eqnarraycolsep
  %% \arraycolsep -> \eqnarraycolsep (must redefine \eqnarray before hyperref)
  \def\eqnarray{%
     \stepcounter{equation}%
     \def\@currentlabel{\p@equation\theequation}%
     \global\@eqnswtrue
     \m@th
     \global\@eqcnt\z@
     \tabskip\@centering
     \let\\\@eqncr
     $$\everycr{}\halign to\displaywidth\bgroup
         \hskip\@centering$\displaystyle\tabskip\z@skip{##}$\@eqnsel
        &\global\@eqcnt\@ne\hskip \tw@\eqnarraycolsep \hfil${##}$\hfil
        &\global\@eqcnt\tw@ \hskip \tw@\eqnarraycolsep
           $\displaystyle{##}$\hfil\tabskip\@centering
        &\global\@eqcnt\thr@@ \hb@xt@\z@\bgroup\hss##\egroup
           \tabskip\z@skip
        \cr
    }%
\fi
%% <<< Math settings <<<

\RequirePackage{dgruyterx-book}
\ifpdf
\else
  \RequirePackage{luafonts}
\fi

\RequirePackage{pagerefsout}

\ifdefined\load@prelims
  \RequirePackage{degruyter-prelims}
\fi

\def\@undefined@ref@color{\color{red}}
\ifdefined\HCode
\else
  \def\@setref#1#2#3{%
    \ifx#1\relax
      \protect\G@refundefinedtrue
      \nfss@text{\reset@font\bfseries\csname @undefined@ref@color\endcsname ??}%
      \@latex@warning{Reference `#3' on page \thepage \space undefined}%
    \else
      \bgroup
        \ifmmode
        \else
          \upshape
        \fi
        \expandafter\Hy@setref@link#1\@empty\@empty\@nil{#2}%
      \egroup
    \fi
    }%
\fi

%% class cfg load
\long\def\@if@vtex@in@house#1#2{\@ifundefined{vtex@in@house}{#2}{#1}}
\iffalse
\IfFileExists{\fmt@name-vtex.cfg}
  {%
    \xdef\vtex@in@house{1}
    \input\fmt@name-vtex.cfg
  }{%
    \input\fmt@name.cfg
  }
\fi

%% \@ifminipage reset to \iffalse at the end of array (dgruyter.sty bugfix)
\g@addto@macro\endarray{\@minipagefalse}

\flushbottom % raggedbottom was set by default

%% >>> GRID >>>
\newif\if@full@grid \@full@gridfalse
\newdimen\dg@grid@rule@wd
\dg@grid@rule@wd=.1bp
\RequirePackage{vtexsavepos}

\newcounter{dg@showgrid@cnt}[page]
\def\dg@showgrid@hrule{{%
  \stepcounter{dg@showgrid@cnt}%
  \edef\@tmp{dg@showgrid@\the\c@dg@showgrid@cnt}%
  \vtexsavepos\@tmp
  \@ifleftcol\@tmp{%
    \if@full@grid
      \rlap{%
      \raisebox{\dimexpr\grid@@numraise-\dg@grid@rule@wd+\dg@vgrid\relax}[\z@][\z@]{\color{cyan}%
        \rule{\dimexpr\textwidth+\grid@@numsep+\grid@@numsep\relax}{\dg@grid@rule@wd}}}%
    \fi
    \rlap{\raisebox{\dimexpr\grid@@numraise-\dg@grid@rule@wd\relax}[\z@][\z@]{\color{cyan}%
      \rule{\dimexpr\textwidth+\grid@@numsep+\grid@@numsep\relax}{\dg@grid@rule@wd}}}%
    }{}%
  }}
\def\showbaselinegrid{%
  \SETGRID
  \let\put@gridnum@left\dg@showgrid@hrule % since combination of line numbers and grid lines is not required
  \let\put@gridnum@right\relax
  %\appto\put@gridnum@left{\dg@showgrid@hrule}% combination allowed
  \AtBeginDocument{%
    \ifnum\doc@stage>100\relax
      \ClassError{\dg@fmt@name}{\string\showbaselinegrid, \string\showfullgrid\space commands cannot\MessageBreak be used at stage=\doc@stage}{}%
    \fi
    }%
  }

\def\showfullgrid{%
  \global\@full@gridtrue
  \showbaselinegrid
  }

\RequirePackage{intcalc}
\newcount\mycounterA
\newcount\mycounterB
\newcount\tempcount
\newcount\@tempcount
\newdimen\rest@skip
%% deep revision required
\def\move@to@grid{%
  \mycounterA=\pagetotal\relax
  \tempcount=\the\mycounterA\relax
  \mycounterB=\dimexpr\dg@vgrid\relax
  \divide\tempcount by\mycounterB
  \@tempcount=\the\tempcount
  \multiply\@tempcount by\mycounterB
  \advance\@tempcount by-\mycounterA
\ifnum\@tempcount=62500\relax
\else
  %\edef\@temp{\intcalcMod{\the\tempcount}{2}}%
  %\ifcase\@temp
  %  \advance\tempcount by 2\relax
  %\else
    \advance\tempcount by 1\relax
  %\fi
  \multiply\tempcount by\mycounterB
  \advance\tempcount by-\mycounterA
  \global\rest@skip=\dimexpr\the\tempcount sp\relax
  \vadjust pre{\vskip\rest@skip}%
\fi
  }
\let\movetogrid\move@to@grid
%% <<< GRID <<<

%% >>> Production stages >>>
%% PROOF: line numbers tagged with /Line<num> objects
\ifpdf
  \def\grid@@font{\rmfamily\small}
\else
  \def\set@@grid@@font{\rmfamily\small}
\fi
\def\grid@@numraise{\z@}%
\ifdefined\HCode
\else
  \appto\PROOF{%
    \let\output@gridnum@left\marked@output@gridnum@left
    \let\output@gridnum@right\marked@output@gridnum@right
    }%
  \ifpdf
    \appto\PROOF{%
      \pdfcatalog{/VTeX:MarkInfo << /LineNMarked true >>}%
      \SETGRID
      }%
  \else
    \appto\PROOF{%
      \special@vtex{mt}{destination}{www}{! [ {Catalog} << /VTeX:MarkInfo << /LineNMarked true >> >> /PUT pdfmark}
      \SETGRID
      }%
  \fi
\fi

\def\marked@output@gridnum@left#1{%
  \mark@pdf@linenum{/Right}{#1}%
  }
\def\marked@output@gridnum@right#1{%
  \mark@pdf@linenum{/Left}{#1}%
  }

\ifpdf
  \def\mark@pdf@linenum#1#2{%
    \pdfliteral page {/Line#2\space << /Pos #1 /Page (\thepage) >> BDC}%
    #2%
    \pdfliteral page {EMC}%
    }
\else
  \@ifundefined{special@mt}{\def\special@mt#1#2#3#4{\special{#1:#2=#3 #4}}}{}
  \@ifundefined{special@vtex}{\def\special@vtex{\special@mt}}{}
  \def\mark@pdf@linenum#1#2{%
    \special@vtex{mt}{destination}{www}{ps: [ /Line#2\space << /Pos #1 /Page (\thepage) >> /BDC pdfmark}%
    #2%
    \special@vtex{mt}{destination}{www}{ps: [ /EMC pdfmark}%
    }
  \def\output@gridnum@left#1{#1}
  \def\output@gridnum@right#1{#1}
  %% pagecrop definitions patched with \output@gridnum@{left/right} (move to pagecrop?)
  \def\put@gridnum@left{%
    \ifnum\@tempcntb=\number\grid@@step\relax
      \ifcase\number\grid@@continues\relax
        \edef\@@gridnum{\number\@tempcnta}%
      \or
        \edef\@@gridnum{\grid@@startnumber}%
      \else
        \edef\@@gridnum{\number\@tempcnta/\grid@@startnumber}%
      \fi
      \expandafter\output@gridnum@left\expandafter{\@@gridnum}%
    \fi
    }
  \def\put@gridnum@right{%
    \ifnum\@tempcntb=\number\grid@@step\relax
      \bgroup
        \@tempcntb=\number\grid@@cnt\relax
        \advance\@tempcnta by\@tempcntb
        \ifcase\number\grid@@continues\relax
          \edef\@@gridnum{\number\@tempcnta}%
        \or
          \edef\@@gridnum{%
            \advance\@tempcntb by\number\grid@@startnumber\relax
            \number\@tempcntb
            }%
        \else
          \edef\@@gridnum{%
            \number\@tempcnta/\advance\@tempcntb by\number\grid@@startnumber\relax
            \number\@tempcntb
            }%
        \fi
        \expandafter\output@gridnum@right\expandafter{\@@gridnum}%
      \egroup
    \fi
    }
\fi

%% Lastpage control
\RequirePackage{vtex-checklpage}
\ifdefined\HCode
\else
  \appto\HPROOF{\check@lpagefalse}
\fi

%% <uncited> control
\RequirePackage{color}
\RequirePackage{vtexqtags}
\appto\HPROOF{\showuncited}
\appto\PROOF{\showuncited}

%% highlighting uncited floats
\let\CHKlabelout\@gobbletwo
\let\refout\@gobble
\def\check@float@citation{%
  \RequirePackage[checkfloats]{vtexfltcheck}%
  \let\old@H@refstepcounter\H@refstepcounter
  \def\H@refstepcounter##1{\old@H@refstepcounter{##1}\xdef\@currentctrname{##1}}%
  \preto\CHK@define{%
    \let\table@boxreset\relax
    \let\figure@boxreset\relax
    }%
  }
\appto\HPROOF{\check@float@citation}
\appto\PROOF{\check@float@citation}

\appto\HPROOF{\global\@pdfdrafttrue}
%% <<< Production stages <<<

%% >>> Preamble >>>
\def\pubyear#1{\gdef\@journalyear{#1}}
\def\firstpage#1{%
  \gdef\@firstpage{#1}%
  \setcounter{page}{#1}%
  }
\def\lastpage#1{\gdef\@lastpage{#1}}
\def\openaccess{\global\let\@openaccess\relax}
\let\freelicensetime\@gobble % needed for packing tool
%% <<< Preamble <<<

%% >>> Frontmatter >>>
\def\articletype#1{\gdef\@articletype{#1}}
\def\pretitle#1{\gdef\@pretitle{#1}}

\let\prefix\@firstofone
\let\fnms\@firstofone
\let\inits\@gobble
\let\snm\@firstofone
\let\suffix\@firstofone
\let\cny\@firstofone
\let\dept\@firstofone
\let\addr\@firstofone
\let\city\@firstofone
\def\bio#1{%
  \csxdef{dg@bio@#1@label}{1}%
  }%
%% Institution (Ringgold)
\define@key{institution}{ring}{\def\institution@ring{#1}}
\def\institution@fmt#1{#1}
\newcommand\institution[2][]{%
  \bgroup
    \setkeys{institution}{#1}%
    \institution@fmt{#2}%
  \egroup
  }
\let\orcid\@gobble

%% pretitle check
\def\research@article@pretitle{Research Article}
\newif\if@hide@pretitle \global\@hide@pretitlefalse
\def\check@if@hide@pretitle{%
  \ifdefined\hide@ra@pretitle
    \ifx\@pretitle\research@article@pretitle
      \global\@hide@pretitletrue
    \fi
  \fi
  }

\long\def\abstract#1{%
  \gdef\@abstract{#1}%
  \check@abstract
  }
\def\keywords#1{%
  \gdef\@keywords{#1}%
  \check@keywords
  }
\def\check@abstract{%
  \ifx\@abstract\@empty
    \ifnum\doc@stage>200\relax
      \ClassError{\dg@fmt@name}{\string\abstract{} cannot be empty at CRC stage!}\@ehc
    \else
      \gdef\@abstract{%
        \bgroup
          \csname @undefined@ref@color\endcsname
          ???%
        \egroup
        }%
    \fi
  \fi
  }
\def\check@keywords{%
  \ifx\@keywords\@empty
    \ifnum\doc@stage>200\relax
      \ClassError{\dg@fmt@name}{\string\keywords{} cannot be empty at CRC stage!}\@ehc
    \else
      \gdef\@keywords{%
        \bgroup
          \csname @undefined@ref@color\endcsname
          ???%
        \egroup
        }%
    \fi
  \fi
  }
%% Keywords seperator
\def\sep{, }

%% Note, Translation, Acknowledgement
\def\define@note@macro#1{%
  \csdef{#1}##1{%
    \csgdef{@#1}{##1}%
    \appto\fnotes@block{%
      \csname #1@fmt\endcsname
      \par
      }%
    }%
  \setpkgattr{#1}{titlefont}{\sffamily\bfseries\small}%
  \setpkgattr{#1}{textfont}{\sffamily\mdseries\small}%
  \csdef{#1@fmt}{%
    \rule\z@\footnotesep
    \bgroup
      \csname #1@titlefont\endcsname
      \csname #1name\endcsname:
    \egroup
    \space
    \bgroup
      \csname #1@textfont\endcsname
      \csname @#1\endcsname
    \egroup
    }
  }
\define@note@macro{note}
\define@note@macro{translation}
\define@note@macro{acknowledgement}
%% <<< Frontmatter <<<

%% >>> Bibliography >>>
\setlength\bibhang\bibindent
\appto\bibpreamble{\clubpenalty150\widowpenalty150}
\def\bibfont{\sffamily\mathversion{ss}\small\RaggedRight\nohyphen}
\def\bibnumfmt#1{[\edef\DGMetaScience@figurealign{T}\sffamily#1]\hfill}
\apptocmd\vtex@thebibliography@start{%
 \ifdefined\@bookbackmatter
   \@pseudochaptertrue
   \renewcommand\bibsection{\chapter*{\refname}}%
 \else
   \renewcommand\bibsection{\section*{\refname}}%
 \fi
 }{}{}
\bibsep\z@\@plus1sp\relax

\def\vtex@qmark@fmt#1{%
  \begingroup
  \reset@font
  \bfseries
  \csname @undefined@ref@color\endcsname
  #1%
  \endgroup
  }%
\def\doi@base{https://doi.org/}
\RequirePackage{vtexbibtags}
\gdef\bparticle#1#{\@latex@error{\string\bparticle{}\space content must be tagged in \string\snm{} command}\@ehc}

\def\auto@bibliography@align{%
  %% Write MAX label to aux
  \def\write@maxwlabel@item{%
    \@ifundefined{maxwlabel@item}
      {}
      {%
        \write\@mainaux{\string\gdef\string\thebibliography@maxwlabel{\maxwlabel@item}}%
      }%
    }
  %% Calculate MAX width item for bibitem label
  \newdimen\maxwlabel@width %0pt
  \def\thebibliography@maxwlabel{0}%
  \def\calc@maxwlabel@item##1{%
    \bgroup
     \settowidth\@tempdima{##1}%
     \ifdim\@tempdima>\maxwlabel@width
       \xdef\maxwlabel@item{##1}%
       \global\maxwlabel@width\@tempdima
     \fi
    \egroup
    }%
  %% Hook to calc MAX width item for bibitem label (valid for 'numbers' option)
  \ifNAT@numbers
    \let\save@NAT@anchor\NAT@anchor
    \def\NAT@anchor##1##2{%
      \calc@maxwlabel@item{##2}%
      \save@NAT@anchor{##1}{##2}%
      }%
  \fi
  \def\vtex@bibsetnum##1{%
    \if.##1.%
      \NAT@bibsetnum{\thebibliography@maxwlabel}%
    \else
      \NAT@bibsetnum{##1}%
    \fi
    }%
  \appto\vtex@thebibliography@end\write@maxwlabel@item
  }
\auto@bibliography@align

\ifcase\bib@style
\or
  \usepackage[noerror]{vancouver-pages}
  \def\start@bibenv@hook{\let\bfpage\vcr@bfpage}
  \usepackage{vtexbptsetup}
  \bptsetup{tool=structpyb,bibstyle=\bib@style@name}
  \special{vtex:settings.structpyb={-split}}
\fi
%% <<< Bibliography <<<

%% >>> Copyright, license >>>
\def\copyrightholder#1{\gdef\@copyrightholder{#1}}
\AtBeginDocument{%
  \ifx\@copyrightholder\undefined
    \ifx\@openaccess\relax
      \gdef\@copyrightholder{???}%
    \else
      \gdef\@copyrightholder{\@copyright@publisher}%
    \fi
  \fi
  }
\gdef\@copyrightyear{\@journalyear}
\def\@copyright@publisher@short{De Gruyter}
\def\@copyright@publisher{Walter de Gruyter GmbH, Berlin/Boston}
\gdef\standard@copyrighttext{%
  \textcopyright\space
  \@copyrightyear\space
  \@copyrightholder
  }
\def\openaccess@copyrighttext@aftersep{.}
\gdef\openaccess@copyrighttext{%
  \textcopyright\space
  \@copyrightyear\space
  \@copyrightholder,\space
  \iflanguage{ngerman}
    {publiziert von}
    {published by}%
  \space
  \@copyright@publisher@short
  \openaccess@copyrighttext@aftersep
  }
\def\@copyrighttext{%
  \ifx\@openaccess\relax
    \openaccess@copyrighttext
  \else
    \standard@copyrighttext
  \fi
  }
\def\book@copyrighttext{%
  \let\@copyright@publisher@short\@copyright@publisher %% Full version of Copyright Publisher in prelims
  \@copyrighttext
  }
\def\license@text{%
  \csname\languagename @license@text\endcsname
  }
\def\english@license@text{%
  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 License.%
  }
\def\ngerman@license@text{%
  Dieses Werk ist lizenziert unter der Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 Lizenz.%
  }
\setpkgattr{openaccess}{logo}{Open_Access}
\gdef\@contributioncopyright{%
  \ifx\@openaccess\relax
    \leavevmode
    \lower0.5mm\hbox{\includegraphics[height=2.8mm]{\openaccess@logo}}%
    \space
    Open Access.%
    \space
    \openaccess@copyrighttext
    \space
    \lower0.5mm\hbox{\includegraphics[height=2.8mm]{by-nc-nd}}%
    \space
    \license@text
  \fi
  }
\def\bookopenaccess@text{%
  \csname\languagename @bookopenaccess@text\endcsname
  }
\def\english@bookopenaccess@text{%
  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives
  4.0 License. For details go to
  \href{http://creativecommons.org/licenses/by-nc-nd/4.0/}{http://creativecommons.org/licenses/by-nc-nd/4.0/}.%
  }
\def\ngerman@bookopenaccess@text{%
  Dieses Werk ist lizenziert unter der Creative Commons Attribution-NonCommercial-NoDerivatives
  4.0 Lizenz. Weitere Informationen finden Sie unter
  \href{http://creativecommons.org/licenses/by-nc-nd/4.0/}{http://creativecommons.org/licenses/by-nc-nd/4.0/}.%
  }
%% <<< Copyright, license <<<

\let\tsup\textsuperscript
\let\tsub\textsubscript

%% >>> Author/address output >>>
\let\saved@refstepcounter\refstepcounter
\RequirePackage{aidstuff}
\let\refstepcounter\saved@refstepcounter

\newtoks\document@frontmatter
\get@env@toks{frontmatter}{\document@frontmatter}
\newtoks\document@aug
\get@env@toks{aug}{\document@aug}

\def\end@add@env@frontmatter@hook{%
  \bgroup
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      ##3%
      }%
    \the\document@frontmatter
    \maketitle
  \egroup
  }

\newcounter{dgauthor}
\newcounter{dgaffil}
\let\address@block@list\relax
\let\coraddress@block@list\relax
\def\address@block@font{\small\sffamily\raggedright\nohyphen}
\def\printead@prefix{,\space}
\def\orcid@prefix{,\space}
\def\orcid@hrefprefix{http://orcid.org/}
\def\ead@prefix@email{e-mail}
\def\ead@prefix@m@email{e-mails}

\DeclareListParser\dosemicommalist{;}

\def\address@block@fmt{%
  \rule\z@\footnotesep
  \coraddress@block@fmt
  \otheraddress@block@fmt
  \nointerlineskip
  }

\def\coraddress@block@fmt{%
  \def\corauthor@pre{*Corresponding author:\space}%
  \def\do##1{%
    \seperate@address@block@fmt{##1}%
    }%
  \expandafter\dosemicommalist\expandafter{\coraddress@block@list}%
  }

\def\otheraddress@block@fmt{%
  \def\do##1{%
    \seperate@address@block@fmt{##1}%
    }%
  \@ifundefined{address@block@list}
    {} % Do not process if only corresponding address block is present
    {\expandafter\dosemicommalist\expandafter{\address@block@list}}%
  }

\def\@extract@affil@ids#1addressblock#2\stop{%
  #2%
  }

\def\seperate@address@block@fmt#1{%
  \csletcs{@author@list}{#1belongsto}%
  \noindent
  \address@block@font\bfseries
  \bgroup
    \def\do##1{%
      \csname corauthor@pre\endcsname
      \global\let\corauthor@pre\relax
      \csuse{author##1},\space
      }%
      \expandafter\docsvlist\expandafter{\@author@list}%
  \egroup
  \mdseries
  \bgroup
    \let\@temp@sep\relax
    \edef\@affil@list{\@extract@affil@ids #1\stop}%
    \def\do##1{%
      \@temp@sep
      \csuse{affil##1}%
      \def\@temp@sep{; and\space}%
      }%
    \expandafter\docsvlist\expandafter{\@affil@list}%
    \ifcsname coraddressblock\@affil@list ead@ids\endcsname
      \printead@prefix
      \expandafter\printead\expandafter{\csname coraddressblock\@affil@list ead@ids\endcsname}%
      \global\csundef{coraddressblock\@affil@list ead@ids}%
    \fi
    \ifcsname addressblock\@affil@list ead@ids\endcsname
      \printead@prefix
      \expandafter\printead\expandafter{\csname addressblock\@affil@list ead@ids\endcsname}%
    \fi
    \ifcsname coraddressblock\@affil@list orcids\endcsname
      \def\do##1{%
        \orcid@prefix
        \href{\orcid@hrefprefix ##1}{\orcid@hrefprefix ##1}%
        }%
      \csletcs{orcid@list}{coraddressblock\@affil@list orcids}%
      \expandafter\docsvlist\expandafter{\orcid@list}%
      \global\csundef{coraddressblock\@affil@list orcids}%
    \fi
    \ifcsname addressblock\@affil@list orcids\endcsname
      \def\do##1{%
        \orcid@prefix
        \href{\orcid@hrefprefix ##1}{\orcid@hrefprefix ##1}%
        }%
      \csletcs{orcid@list}{addressblock\@affil@list orcids}%
      \expandafter\docsvlist\expandafter{\orcid@list}%
    \fi
  \egroup
  \par
  }

\def\print@address@block{%
  \bgroup
    \DeclareRobustCommand\ead[2][]{{%
      \setkeys{ead}{label={},email,##1}%
      \@setead{\ead@id}{options}{##1}%
      \@setead{\ead@id}{type}{\ead@type}%
      \@setead{\ead@id}{value}{##2}%
      \ifx\@currentaddressblock@corresp\@undefined
        \@ifundefined{addressblock\@currentaddressblock ead@ids}
          {%
            \csxdef{addressblock\@currentaddressblock ead@ids}{\ead@id}%
          }{%
            \csxappto{addressblock\@currentaddressblock ead@ids}{,\ead@id}%
          }%
      \else
        \@ifundefined{coraddressblock\@currentaddressblock ead@ids}
          {%
            \csxdef{coraddressblock\@currentaddressblock ead@ids}{\ead@id}%
          }{%
            \csxappto{coraddressblock\@currentaddressblock ead@ids}{,\ead@id}%
          }%
      \fi
      }\ignorespaces}%
    \def\orcid##1{%
      \def\orcid@value{##1}%
      \ifx\@currentaddressblock@corresp\@undefined
        \@ifundefined{addressblock\@currentaddressblock orcids}
          {%
            \csxdef{addressblock\@currentaddressblock orcids}{\orcid@value}%
          }{%
            \csxappto{addressblock\@currentaddressblock orcids}{,\orcid@value}%
          }%
      \else
        \@ifundefined{coraddressblock\@currentaddressblock orcids}
          {%
            \csxdef{coraddressblock\@currentaddressblock orcids}{\orcid@value}%
          }{%
            \csxappto{coraddressblock\@currentaddressblock orcids}{,\orcid@value}%
          }%
      \fi
      }%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\author{%
        \@ifstar
         {\let\cor@author\relax\dg@auth@r}
         {\let\cor@author\@undefined\dg@auth@r}}%
      \setcounter{dgauthor}{0}%
      \newcommand\dg@auth@r[2][]{%
        \stepcounter{dgauthor}%
        \edef\dg@temp{\the\c@dgauthor}%
        \ifx\cor@author\relax
          \csdef{author\the\c@dgauthor}{%
            \edef\@currentaddressblock{####1}%
            \edef\@currentaddressblock@corresp{1}%
            ####2%
            }%
        \else
          \csdef{author\the\c@dgauthor}{%
            \edef\@currentaddressblock{####1}%
            \let\@currentaddressblock@corresp\@undefined
            ####2%
            }%
        \fi
        \ifx\cor@author\relax
          \@ifundefined{coraddressblock####1belongsto}
            {%
              \cslet{coraddressblock####1belongsto}{\dg@temp}%
              \ifx\coraddress@block@list\relax
                \cseappto{coraddress@block@list}{coraddressblock####1}%
              \else
                \cseappto{coraddress@block@list}{;coraddressblock####1}%
              \fi
            }{%
              \cseappto{coraddressblock####1belongsto}{,\dg@temp}%
            }%
        \else
          \@ifundefined{addressblock####1belongsto}
            {%
              \cslet{addressblock####1belongsto}{\dg@temp}%
              \ifx\address@block@list\relax
                \cseappto{address@block@list}{addressblock####1}%
              \else
                \cseappto{address@block@list}{;addressblock####1}%
              \fi
            }{%
              \cseappto{addressblock####1belongsto}{,\dg@temp}%
            }%
        \fi
        }%
      \setcounter{dgaffil}{0}%
      \let\affil\undefined
      \newcommand\affil[2][]{%
        \stepcounter{dgaffil}%
        \edef\dg@temp{\the\c@dgaffil}%
        \csdef{affil\the\c@dgaffil}{####2}%
        }%
      ##3%
      }%
    \the\document@aug
    \address@block@fmt
  \egroup
  }

\let\author@block@list\relax
\def\corresp@author@mark{*}
\def\author@block@font{\large\sffamily\raggedright\nohyphen}
\def\print@author@block{%
  \bgroup
    \DeclareRobustCommand\ead[2][]{{\relax}}%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\author{%
        \@ifstar
         {\let\cor@author\relax\dg@auth@r}
         {\let\cor@author\@undefined\dg@auth@r}}%
      \setcounter{dgauthor}{0}%
      \newcommand\dg@auth@r[2][]{%
        \stepcounter{dgauthor}%
        \xdef\number@of@authors{\the\c@dgauthor}%
        \csdef{author\the\c@dgauthor}{%
          ####2%
          }%
        \ifx\cor@author\relax
          \csdef{author\the\c@dgauthor corresp}{1}%
        \else
          \cslet{author\the\c@dgauthor corresp}{\@undefined}%
        \fi
        \ifx\author@block@list\relax
          \cseappto{author@block@list}{author\the\c@dgauthor}%
        \else
          \cseappto{author@block@list}{,author\the\c@dgauthor}%
        \fi
        \ignorespaces
        }%
      \let\affil\undefined
      \newcommand\affil[2][]{\ignorespaces}%
      ##3%
      }%
    \the\document@aug
    \author@block@fmt
  \egroup
  }

%% Write author contentsline to aux setup
\def\namemodel@toc{%
  \def\prefix{\string\prefix}%
  \let\inits\@gobble
  \def\fnms##1{\string\fnms{\detokenize{##1}}}%
  \def~{\space}%
  \def\snm##1{\string\snm{\detokenize{##1}}}%
  \def\collab##1{\string\collab{\detokenize{##1}}}%
  \def\suffix{\string\suffix}%
  \let\affprefix\@gobbletwo
  \def\degress{\string\degress}%
  \def\particle{\string\particle}%
  \def\ead[##1]##2{}%
  }
\newtoks\@tocauthor@list
\def\add@tocauthorlist#1{%
  \begingroup
    %\no@harm
    \let\addressref\@gobble
    \xdef\@act{%
      \global\noexpand\@tocauthor@list{\the\@tocauthor@list#1}%
      }%
    \@act
  \endgroup
  }

\newcounter{temp@author@cnt}
\def\author@block@fmt{%
  \bgroup
    \author@block@font
    \let\author@prefix\relax
    \def\do##1{%
      \stepcounter{temp@author@cnt}%
      \ifnum\c@temp@author@cnt>\@ne
        \ifnum\c@temp@author@cnt=\number@of@authors
          \ifnum\number@of@authors=\tw@
            \def\author@prefix{ and\space}%
          \else
            \def\author@prefix{, and\space}%
          \fi
        \else
          \def\author@prefix{,\space}%
        \fi
      \fi
      \author@prefix
      \csuse{##1}%
      %\@ifundefined{##1corresp}
      %  {}
      %  {\corresp@author@mark}%
      }%
    \expandafter\docsvlist\expandafter{\author@block@list}%
    \par
    %% Collect author contentsline
    \def\do##1{%
      \bgroup
        \namemodel@toc
        \xdef\toc@author{\string\author{\csuse{##1}}}%
        \add@tocauthorlist{\toc@author}%
      \egroup
      }
    \expandafter\docsvlist\expandafter{\author@block@list}%
    %% Write author contentsline to aux file
    %% Manual writing in order to prevent bookmarks entry
    \immediate\write\@auxout{%
      \string\@writefile{toc}{\string\contentsline{author}{\the\@tocauthor@list}{\thepage}{}}%
      }%
  \egroup
  }

\def\running@two@author@sep{\space and\space}
\def\running@etal@post{\space et al.}
\def\running@author@fmt{%
  \bgroup
    \ifcase\number@of@authors
    \or
      \edef\@temp@running{\csuse{author1}}%
    \or
      \edef\@temp@running{%
        \csuse{author1}%
        \running@two@author@sep
        \csuse{author2}%
        }%
    \else
      \edef\@temp@running{%
        \csuse{author1}%
        \running@etal@post
        }%
    \fi
    \@ifundefined{@runningauthor}
      {\global\let\@runningauthor\@temp@running}
      {}%
  \egroup
  }

\def\define@running@author{%
  \bgroup
    \let\ead\@undefined
    \def\ead##1##{\@gobble}%
    \def\inits##1{##1}%
    \let\fnms\@gobble
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\author{%
        \@ifstar
         {\let\cor@author\relax\dg@auth@r}
         {\let\cor@author\@undefined\dg@auth@r}}%
      \setcounter{dgauthor}{0}%
      \newcommand\dg@auth@r[2][]{%
        \stepcounter{dgauthor}%
        \xdef\running@number@of@authors{\the\c@dgauthor}%
        \csedef{author\the\c@dgauthor}{%
          ####2%
          }%
        \ignorespaces
        }%
      \let\affil\undefined
      \newcommand\affil[2][]{\ignorespaces}%
      ##3%
      }%
    \the\document@aug
    \running@author@fmt
  \egroup
  }
\def\define@default@mark{%
  \if@monography
  \else
    \markleft{\@runningauthor}%
  \fi
  }
\def\review@running@head@fmt{%
  \markboth{Reviews}{Reviews}%
  }
%% <<< Author/address output <<<

%% >>> Author/address block implementation as noteins >>>
\RequirePackage{stfloats}
\RequirePackage{fnotes}
\let\fnoterule\relax % We output rule inside every \fnote
\setlength{\skip\noteins}{11\p@}% vertical space between footnote baseline and fnote baseline (22.3bp)
\dimen\noteins=20\baselineskip % maximum footnotes per page
\setpkgattr{dgfnote}{preskip}{14.3\p@}% vertical space between baselines of two fnotes (22.3bp)

\long\def\fnote#1{%
  \insert\noteins{%
    %% If more than one fnote is outputed, we add respective vertical space (adjusted with previous fnote depth)
    \ifdefined\fnote@added
      \vskip\dgfnote@preskip
      \ifdim\last@fnote@prevdepth>\z@
        \ifdim\last@fnote@prevdepth<\maxdimen
          \addvspace{-\last@fnote@prevdepth}%
        \fi
      \fi
    \fi
    \footnoterule
    \reset@font\footnotesize
    \interlinepenalty\interfootnotelinepenalty
    \splittopskip\footnotesep
    \splitmaxdepth \dp\strutbox \floatingpenalty \@MM
    \hsize\columnwidth \@parboxrestore
    \color@begingroup
    \ignorespaces#1%\@finalstrut\strutbox % Author/address block last baseline should be located at the bottom of type area (zero depth)
    \color@endgroup
    %% Save previous fnote depth
    \xdef\last@fnote@prevdepth{\the\prevdepth}%
    }%
  \gdef\fnote@added{1}%
  }%
%% <<< Author/address block implementation as noteins <<<

%% >>> Floats >>>
\if@secfloat
  \@addtoreset{figure}{section}
  \@addtoreset{table}{section}
  \renewcommand\thefigure{\thesection.\@arabic\c@figure}
  \renewcommand\thetable{\thesection.\@arabic\c@table}
\fi
%% <<< Floats <<<

%% >>> Appendix >>>
\def\appendix@name{Appendix}
\def\app@label@sep{.}
\let\app@sv@section\section
\def\@appsectionstar#1{%
  \if@seceqn\refstepcounter{section}\fi%
  \ifx&#1&%
    \app@sv@section*{\appendix@name}%
  \else
    \app@sv@section*{\appendix@name\app@label@sep\enspace #1}%
  \fi
  }
\def\@appsectionnostar#1{%
  \refstepcounter{section}%
  \ifx&#1&%
    \app@sv@section*{\appendix@name\ \thesection}%
  \else
    \app@sv@section*{\appendix@name\ \thesection\app@label@sep\enspace #1}%
  \fi
  }
%% Chapter level appendix
\def\appendix{%
  \setcounter{section}{0}%
  \setcounter{subsection}{0}%
  \def\thesection{\app@num{section}}%
  \def\theHsection{\app@num{section}}%
  \def\section{\@ifstar\@appsectionstar\@appsectionnostar}%
  }
%% Book level appendix
\def\bookappendix{%
  \@pseudochaptertrue
  \@bookappendixtrue
  \setcounter{chapter}{0}%
  \setcounter{section}{0}%
  \setcounter{subsection}{0}%
  \def\thechapter{\Alph{chapter}}%
  }
%% <<< Appendix <<<

%% >>> Funding >>>
\define@key{gsponsor}{id}{\def\gsponsor@id{#1}}
\define@key{gsponsor}{sponsor-id}{\def\gsponsor@sponsorid{#1}}
\define@key{gnumber}{refid}{\def\gnumber@refid{#1}}

\def\gsponsor@fmt#1{#1}
\def\gnumber@fmt#1{#1}

\newcommand\gsponsor[2][]{%
  \bgroup
    \setkeys{gsponsor}{#1}%
    \gsponsor@fmt{#2}%
  \egroup
  }
\newcommand\gnumber[2][]{%
  \bgroup
    \setkeys{gnumber}{#1}%
    \gnumber@fmt{#2}%
  \egroup
  }
%% <<< Funding <<<

%% >>> Bionotes >>>
\def\bionotesname{Bionotes}
\newenvironment{bionotes}
  {%
    \goodbreak
    \vskip2\baselineskip
    \@afterindentfalse
    {%
      \parindent\z@
      \raggedright
      \ifdim\pagetotal=\z@
        \leavevmode\vrule\@width\z@\@height\dimexpr\topskip+0.5\baselineskip\relax\@depth\z@
      \fi
      \sffamily\bfseries\Large
      \interlinepenalty\@M
      \bionotesname\par\nobreak
      \vskip 13\p@
    }%
    \@afterheading
  }
  {}

\newcommand\contributor[6]{%
  \@ifundefined{dg@bio@#1@label}
    {\ClassError{\dg@fmt@name}{One of the \string\author{} commands must contain \string\bio{#1}!}\@ehc}
    {}%
  \goodbreak
  {%
    \sffamily\small
    \if!#5!\else\leftskip30mm\fi
    \noindent
    \if!#5!\else
      \ifx\f@rmat b\vrule\@width\z@\@depth29.8mm\fi
      \llap{%
        \if!#6!\else\expandafter\smash\fi
          {\lower29.8mm\hb@xt@26mm{%
            \includegraphics[width=26mm,height=32mm]{#5}\hss}\kern4mm}}%
    \fi
    \parbox[t]{\dimexpr\hsize-\leftskip}{%
      \raggedright
      \bfseries#2\par
      \mdseries#3%
      \if!#4!\else
        \ifx\f@rmat b\par\else,\space\fi
        \bfseries#4
      \fi
      }%
    \par\vskip\baselineskip
    \if!#5!\else
      \RaggedRight
      \ifx\f@rmat b\else\leftskip30mm\fi
    \fi
    \noindent#6\par
  }%
  \vskip2\baselineskip
  \def\@tempa{multicols}%
  \ifx\@currenvir\@tempa
    \vskip\z@\@plus\baselineskip\@minus0.5\baselineskip
  \fi
  }
%% <<< Bionotes <<<

%% >>> Tables >>>
\let\tablebr\break

\RequirePackage{tabnotes}
\ifnum\bookstart@date@info>20180129\relax
  \renewcommand*\tablefont{%
    \setDGmathMonospasedNumbers
    \edef\DGMetaScience@figurealign{T}%
    \sffamily
    \mathversion{ss}%
    \addfontfeature{Numbers=Monospaced}%
    \small
    }
  \renewcommand*\tableheadfont{%
    \setDGmathMonospasedNumbers
    \small
    \sffamily
    \addfontfeature{Numbers=Monospaced}%
    \bfseries
    \mathversion{ssbold}%
    }
  \def\tabnotes@font{%
    \setDGmathMonospasedNumbers
    \sffamily
    \mathversion{ss}%
    \addfontfeature{Numbers=Monospaced}%
    }
\else
  \def\tabnotes@font{\sffamily\mathversion{ss}\addfontfeature{Numbers=Monospaced}}
\fi
\def\tabnoteref@font{\tabnotes@font}
\def\tabnotetext@mark@font{\tabnotes@font}
\appto\before@tabnotetext@text{\tabnotes@font}
%% <<< Tables <<<

%% >>> LaTeX quality checker configuration >>>
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{cmn}{cmn\string_dg\string_all}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{cmn}{cmn\string_dg\string_front}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{cmn}{cmn\string_dg\string_body}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{cmn}{cmn\string_vln\string_all}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{cmn}{cmn\string_vln\string_ext}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{ltx}{ltx\string_dg\string_body}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{xml}{xml\string_dg\string_all}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{ltx}{ltx\string_dg\string_biblio}}
\protected@write\@auxout{}{\string\vktinfo{kt-ltx-chk}{cmn}{cmn\string_dg\string_preamble}}
\let\vktinfo\@gobblethree
%% <<< LaTeX quality checker configuration <<<

%% >>> Abbreviation group >>>
\def\abbrsection#1{%
  \ifdefined\dg@abbrgroup@chaptertitle
    \edef\section@indent{-\leftmargin}%
    \nocontentsline
    \section*{#1}%
  \else
    \edef\subsection@indent{-\leftmargin}%
    \nocontentsline
    \subsection*{#1}%
  \fi
  }
\define@key{abbrgroup}{title}{\def\dg@abbrgroup@title{#1}}
\define@key{abbrgroup}{chaptertitle}{\def\dg@abbrgroup@chaptertitle{#1}}
\define@key{abbrgroup}{notitle}[true]{\edef\dg@abbrgroup@notitle{1}}
\def\abbrgroup@labelwidth{0pt}
\newenvironment{abbrgroup}[1][title={Abbreviations}]%
  {%
    \@pseudochaptertrue
    \setkeys{abbrgroup}{#1}%
    \def\abbrgroup@@labelwidth{0pt}%
    \ifdefined\dg@abbrgroup@notitle
    \else
      \ifdefined\dg@abbrgroup@chaptertitle
        \chapter*{\dg@abbrgroup@chaptertitle}%
      \else
        \section*{\dg@abbrgroup@title}%
      \fi
    \fi
    \list{}
      {%
        \labelwidth\abbrgroup@labelwidth
        \labelsep=1em%
        \leftmargin\labelwidth
        \advance\leftmargin\labelsep
        \let\makelabel\abbrgrouplabel
      }%
  }{%
    \protected@write\@auxout{}{\string\gdef\string\abbrgroup@labelwidth{\abbrgroup@@labelwidth}}%
    \endlist
  }
\newcommand*\abbrgrouplabel[1]{%
  \normalfont
  \settowidth\@tempdima{#1}%
  \ifdim\@tempdima>\abbrgroup@@labelwidth
    \xdef\abbrgroup@@labelwidth{\the\@tempdima}%
  \fi
  #1%
  }

%% for {bookmisc} interface
\def\process@abbrgroup{%
  \ifdefined\bookmisc@chaptertitle
    \def\dg@abbrgroup@chaptertitle{1}%
  \fi
  }
%% <<< Abbreviation group <<<

%% >>> Book review >>>
\newif\iffirst@bookreview \global\first@bookreviewtrue
\newenvironment{bookreview}
  {%
    \global\let\@review\relax
    \global\let\@pretitle\@undefined
    \global\let\@title\@undefined
    \document@frontmatter={}%
    \document@aug={}%
    \document@product={}%
    \def\firstpage##1{%
      \gdef\@firstpage{##1}%
      \iffirst@bookreview
        \setcounter{page}{##1}%
      \fi
      }%
  }{%
    \global\first@bookreviewfalse
  }

\newtoks\document@product
\get@env@toks{product}{\document@product}

\def\product@fmt{%
  \bgroup
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      ##3%
      }%
    \the\document@product
    \par
  \egroup
  }

\def\print@review@address@block{%
  \bgroup
    \DeclareRobustCommand\ead[2][]{{%
      \setkeys{ead}{label={},email,##1}%
      \@setead{\ead@id}{options}{##1}%
      \@setead{\ead@id}{type}{\ead@type}%
      \@setead{\ead@id}{value}{##2}%
      \@ifundefined{addressblock\@currentaddressblock ead@ids}
        {%
          \csxdef{addressblock\@currentaddressblock ead@ids}{\ead@id}%
        }{%
          \csxappto{addressblock\@currentaddressblock ead@ids}{,\ead@id}%
        }%
      }\ignorespaces}%
    \def\orcid##1{%
      \def\orcid@value{##1}%
      \@ifundefined{addressblock\@currentaddressblock orcids}
        {%
          \csxdef{addressblock\@currentaddressblock orcids}{\orcid@value}%
        }{%
          \csxappto{addressblock\@currentaddressblock orcids}{,\orcid@value}%
        }%
      }%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\author{%
        \@ifstar
         {\let\cor@author\relax\dg@auth@r}
         {\let\cor@author\@undefined\dg@auth@r}}%
      \setcounter{dgauthor}{0}%
      \let\dg@auth@r\@undefined
      \newcommand\dg@auth@r[2][]{%
        \stepcounter{dgauthor}%
        \edef\dg@temp{\the\c@dgauthor}%
        \ifx\cor@author\relax
          \csdef{author\the\c@dgauthor}{%
            \edef\@currentaddressblock{####1}%
            \edef\@currentaddressblock@corresp{1}%
            ####2%
            }%
        \else
          \csdef{author\the\c@dgauthor}{%
            \edef\@currentaddressblock{####1}%
            \let\@currentaddressblock@corresp\@undefined
            ####2%
            }%
        \fi
        \@ifundefined{addressblock####1belongsto}
          {%
            \cslet{addressblock####1belongsto}{\dg@temp}%
            \ifx\address@block@list\relax
              \cseappto{address@block@list}{addressblock####1}%
            \else
              \cseappto{address@block@list}{;addressblock####1}%
            \fi
          }{%
            \cseappto{addressblock####1belongsto}{,\dg@temp}%
          }%
        }%
      \setcounter{dgaffil}{0}%
      \let\affil\undefined
      \newcommand\affil[2][]{%
        \stepcounter{dgaffil}%
        \edef\dg@temp{\the\c@dgaffil}%
        \csdef{affil\the\c@dgaffil}{####2}%
        }%
      ##3%
      }%
    \the\document@aug
    \review@address@block@fmt
  \egroup
  }

\def\review@address@block@fmt{%
  \def\do##1{%
    \review@seperate@address@block@fmt{##1}%
    }%
  \@ifundefined{address@block@list}
    {} % Do not process if only corresponding address block is present
    {\expandafter\dosemicommalist\expandafter{\address@block@list}}%
  %\nointerlineskip
  }

\def\review@seperate@address@block@fmt#1{%
  \csletcs{@author@list}{#1belongsto}%
  \noindent
  \address@block@font
  \bgroup
    \def\do##1{%
      \csname corauthor@pre\endcsname
      \global\let\corauthor@pre\relax
      \reviewedbyname\space
      \textbf{\csuse{author##1}}:\space
      }%
      \expandafter\docsvlist\expandafter{\@author@list}%
  \egroup
  \mdseries
  \bgroup
    \let\@temp@sep\relax
    \edef\@affil@list{\@extract@affil@ids #1\stop}%
    \def\do##1{%
      \@temp@sep
      \csuse{affil##1}%
      \def\@temp@sep{; and\space}%
      }%
    \expandafter\docsvlist\expandafter{\@affil@list}%
    \ifcsname addressblock\@affil@list ead@ids\endcsname
      \printead@prefix
      \expandafter\printead\expandafter{\csname addressblock\@affil@list ead@ids\endcsname}%
    \fi
    \global\csletcs{addressblock\@affil@list ead@ids}{@undefined}%
    \ifcsname addressblock\@affil@list orcids\endcsname
      \def\do##1{%
        \orcid@prefix
        \href{\orcid@hrefprefix ##1}{\orcid@hrefprefix ##1}%
        }%
      \csletcs{orcid@list}{addressblock\@affil@list orcids}%
      \expandafter\docsvlist\expandafter{\orcid@list}%
    \fi
  \egroup
  \par
  }
%% <<< Book review <<<

%% >>> Book frontmatter >>>
\def\transtitle#1{\def\@transtitle{#1}}
\def\distributionseries#1{\def\@distributionseries{#1}}
\let\@distributionseries\@empty
\def\seriestitle#1{\gdef\@seriestitle{#1}}
\def\transseriestitle#1{\def\@transseriestitle{#1}}
\def\seriessubtitle#1{\gdef\@seriessubtitle{#1}}
\def\seriesabbreviation#1{\gdef\@seriesabbreviation{#1}}
\def\seriesvolume#1{\gdef\@seriesvolume{#1}}
\def\subtitle#1{\gdef\@subtitle{#1}}
\def\serieseditor#1{\gdef\@serieseditor{#1}}
\def\collaborator#1{\gdef\@collaborator{#1}}
\def\edition#1{%
  \ifnum #1<2\relax
  \else
    \gdef\@edition{#1}%
  \fi
  }
\def\editor#1{\gdef\@editor{#1}}
\def\authorinfo#1{\gdef\@authorinfo{#1}}
\def\isbn#1{\gdef\@isbn{#1}}
\def\eisbnepub#1{\gdef\@eisbnepub{#1}}
\def\eisbnpdf#1{\gdef\@eisbnpdf{#1}}
\def\setisbn#1{\gdef\@setisbn{#1}}
\def\issn#1{\gdef\@issn{#1}}
\def\copyrightyear#1{\gdef\@copyrightyear{#1}}
\def\cover#1{\gdef\@cover{#1}}
\def\typesetter#1{\gdef\@typesetter{#1}}
\def\printbind#1{\gdef\@printbind{#1}}

\newtoks\document@bookmeta
\get@env@toks{bookmeta}{\document@bookmeta}
\newtoks\document@authorgroup
\get@env@toks{authorgroup}{\document@authorgroup}
\newtoks\document@editorgroup
\get@env@toks{editorgroup}{\document@editorgroup}
\newtoks\document@bookkeywords
\get@env@toks{bookkeywords}{\document@bookkeywords}

\newif\if@editedbook
\def\book@twoauthorsep{\space and\space}
\def\book@twoeditorsep{\space and\space}
\gdef\book@authorsep{,\space}
\gdef\book@lastauthorsep{, and\space}
\def\define@book@authors@editors{%
  \bgroup
    \def\ead##1##{\@gobble}%
    \let\prefix\@gobble
    \let\author@block@list\relax
    \def\author{%
      \@ifstar
       {\let\cor@author\relax\dg@auth@r}
       {\let\cor@author\@undefined\dg@auth@r}}%
    \let\editor\author
    \setcounter{dgauthor}{0}%
    \newcommand\dg@auth@r[2][]{%
      \stepcounter{dgauthor}%
      \xdef\number@of@authors{\the\c@dgauthor}%
      \csdef{author\the\c@dgauthor}{%
        ##2%
        }%
      \ifx\author@block@list\relax
        \cseappto{author@block@list}{author\the\c@dgauthor}%
      \else
        \cseappto{author@block@list}{,author\the\c@dgauthor}%
      \fi
      \ignorespaces
      }%
    \let\affil\undefined
    \newcommand\affil[2][]{\ignorespaces}%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\@tempa{##1}%
      \def\@temp@editorgroup{editorgroup}%
      \ifx\@tempa\@temp@editorgroup
        \global\@editedbooktrue
      \fi
      ##3%
      }%
    \the\document@authorgroup
    \the\document@editorgroup
    \let\author@prefix\@empty
    \let\temp@authors\@empty
    \setcounter{temp@author@cnt}{0}%
    \def\do##1{%
      \stepcounter{temp@author@cnt}%
      \ifnum\c@temp@author@cnt>\@ne
        \ifnum\c@temp@author@cnt=\number@of@authors
          \ifnum\number@of@authors=\tw@
            \def\author@prefix{\book@twoauthorsep}%
          \else
            \def\author@prefix{\book@lastauthorsep}%
          \fi
        \else
          \def\author@prefix{\book@authorsep}%
        \fi
      \fi
      \cseappto{temp@authors}{%
        \author@prefix
        \ignorespaces
        \csuse{##1}%
        }%
      }%
    \expandafter\docsvlist\expandafter{\author@block@list}%
    \if@editedbook
      \@ifundefined{book@editors}
        {\global\let\book@editors\temp@authors}
        {}%
    \else
      \@ifundefined{book@authors}
        {\global\let\book@authors\temp@authors}
        {}%
    \fi
  \egroup
  }

\def\makebookprelims{%
  \bgroup
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      ##3%
      }%
    \the\document@bookmeta
    \define@book@authors@editors
    \makebooktitle
    \setfmdoisuffix
  \egroup
  }

\def\dg@barpage@tail{%
  \par
  \if@tempswa
    \twocolumn
  \else
    \vfil\break
  \fi
  }
\long\def\dg@barpage#1#2{%
  \if@twocolumn
    \onecolumn
    \@tempswatrue
  \else
    \@tempswafalse
  \fi
  \bgroup
    \thispagestyle{empty}%
    \ifx\f@rmat s
      \@tempdima\dimexpr98.52mm-3.5mm-\topmargin-\headheight-\headsep\relax
    \else
      \ifx\f@rmat m
        %% 281.6\p@ = 37.434mm + 19.5\p@ + 156\p@
        \@tempdima\dimexpr281.6\p@-\topmargin-\headheight-\headsep\relax
      \else
        \@tempdima\dimexpr101.347mm-3.5mm-\topmargin-\headheight-\headsep\relax
      \fi
    \fi
    \parindent\z@
    \ifdefined\pageIII@fixed@false
      \vbox to\@tempdima{#1}%
    \else
      \vbox to\@tempdima{\vss#1}%
    \fi
    \par\nointerlineskip
    {\fontsize{16}{13}\sffamily\dg@barone}%
    \par
    \nointerlineskip
    \vskip8\p@ % 13\p@ between the bottom of DGbar and the top of the following text
    #2\par
  \egroup
  \dg@barpage@tail
  }

\def\book@title{\@title}
\def\book@titlefontsize@small{\fontsize{24}{26}}
\def\book@titlefontsize@medium{\fontsize{33}{35.1}}
\def\book@titlefontsize@big{\fontsize{42}{45.5}}
\def\book@edition{%
  \ifdefined\@edition
    \iflanguage{ngerman}
      {\@edition. Auf\/lage}
      {}%
    \iflanguage{english}
      {\@edition\edition@abbr\space edition}
      {}%
  \fi
  }
\def\edition@abbr{%
  \ifcase\@edition
  \or
    st%
  \or
    nd%
  \or
    rd%
  \else
    th%
  \fi
  }
%% first page editors suffix hook
\def\book@editors@postfix{}
\def\makebooktitle{%
  \if@twocolumn
    \onecolumn
    \@tempswatrue
  \else
    \@tempswafalse
  \fi
  \bgroup
    \thispagestyle{empty}%
    \parindent\z@
    \raggedright
    \sffamily
    \normalsize
    \ifx\book@authors\@undefined
      \book@editors
      \book@editors@postfix
    \else
      \book@authors
    \fi
    \par
    \textbf{\@title}\par
    \@distributionseries\par
    \vfill
    \break
    %% Series page (page II)
    \ifx\@seriestitle\@undefined
      \thispagestyle{empty}%
      \null\par
      \ifx\@makeadvertisement\@empty
      \else
        \ifx\r@makeadvertisement\@undefined\@makeadvertisement\fi
      \fi
      \break
    \else
      \dg@barpage
        {%
          \vbox to156\p@{{%
            \ifx\f@rmat b\relax
              \fontsize{33}{35.1}%
            \else
              \Huge
            \fi
            \bfseries\@seriestitle
            \ifx\@transseriestitle\@undefined
            \else
              \par\bigskip\mdseries\@transseriestitle
            \fi
            \par\vfill
            }}%
        }{%
          \ifx\@seriessubtitle\@undefined
          \else
            {%
              \ifx\f@rmat b\relax
                \Huge
              \else
                \fontsize{14}{17}%
              \fi
              \rmfamily\@seriessubtitle\par
            }%
            \vskip34\p@
          \fi
          \edef\@serieseditorgroup@tokenlist{\the\document@serieseditorgroup}%
          \ifx\@serieseditorgroup@tokenlist\@empty
          \else
            \print@page@two@serieseditorgroup
            \vskip13\p@
          \fi
          \ifx\@serieseditor\@undefined
          \else
            {%
              \fontsize{14}{17}\selectfont
              \setbox\z@\hbox{\@serieseditor}%
              \ifdim\wd\z@>\hsize
                \normalsize
              \fi
              \iflanguage{ngerman}
                {Herausgegeben von}
                {Editor in Chief}%
              \par
              \@serieseditor
              \par
            }%
            \vskip17\p@
          \fi
          \ifx\@seriesvolume\@undefined\else
            {%
              \Huge\bfseries
              \iflanguage{ngerman}{Band}{Volume}%
              \space\@seriesvolume
              \par
            }%
          \fi
        }%
    \fi
    %% Title page (page III)
    \dg@barpage
      {%
        \ifx\book@authors\@undefined
        \else
          \setbox\z@\hbox{\Huge\book@authors}%
          \ifdim\wd\z@>\hsize
            \LARGE
          \else
            \Huge
          \fi
          \book@authors
          \par
        \fi
        %% strict 19.5\p@ vertical space between author baseline and top of the title box
        \ifdim\prevdepth>\z@
          \ifdim\prevdepth<\maxdimen
            \addvspace{-\prevdepth}%
          \fi
        \fi
        \nointerlineskip
        \vskip19.5\p@
        \setbox\z@\vbox{%
          \book@titlefontsize@big\bfseries\@title
           \ifx\@transtitle\@undefined
           \else
             \par\bigskip\mdseries\@transtitle
           \fi}%
        \ifdim\ht\z@<140\p@
          \let\title@fontsize\book@titlefontsize@big
        \else
          \setbox\z@\vbox{%
            \book@titlefontsize@medium\bfseries\@title
            \ifx\@transtitle\@undefined
            \else
              \par\bigskip\mdseries\@transtitle
            \fi}%
          \ifdim\ht\z@<150\p@
            \let\title@fontsize\book@titlefontsize@medium
          \else
            \let\title@fontsize\book@titlefontsize@small
          \fi
        \fi
        \ifdefined\book@titlefontsize
          \csletcs{title@fontsize}{book@titlefontsize@\book@titlefontsize}%
        \fi
        \vbox to156\p@{%
          \title@fontsize
          \bfseries
          \book@title
          \ifx\@transtitle\@undefined
          \else
            \par\bigskip\mdseries\@transtitle
          \fi
          \par\vss
          }%
      }{%
        \fontsize{14}{17}\selectfont
        \ifx\@subtitle\@undefined
        \else
          {%
            \rmfamily
            \ifx\f@rmat b\relax
              \Huge
            \fi
            \@subtitle\par
          }%
          \vskip34\p@
        \fi
        \if@editedbook
          \print@page@three@editorgroup
          \par\vskip17\p@
        \fi
        \ifx\@collaborator\@undefined
        \else
          \iflanguage{ngerman}{In Zusammenarbeit mit}{Editors}\\
          \@collaborator
          \par\vskip17\p@
        \fi
        \ifx\book@edition\@undefined
        \else
          \book@edition
          \par\vskip17\p@
        \fi
        \vfill
        \ifx\f@rmat b\relax
          \includegraphics[scale=1.143]{\@publisherlogo}%
        \else
          \includegraphics{\@publisherlogo}%
        \fi
        \hskip7mm %%fill in cooperator-logo here
        \csname titlepage@cooperatorlogo\endcsname %% User may include additional logos
        \par
      }%
    %% Publishing information (page IV)
    \thispagestyle{empty}%
    \small
    \multicolsep\z@
    %\ifx\@classification\@undefined
    %\else
    %  \vskip0.5\baselineskip
    %  \ifx\classificationName\@undefined
    %    \let\classificationName\classificationname
    %  \fi
    %  {\bfseries\classificationName\par}%
    %  \@classification
    %  \par
    %  \vskip\baselineskip
    %  \global\let\@classification\@undefined
    %\fi
    \edef\@bookkeywords@tokenlist{\the\document@bookkeywords}%
    \ifx\@bookkeywords@tokenlist\@empty
    \else
      \print@page@four@bookkeywords
      \par
      \vskip\baselineskip
    \fi
    \print@page@four@address@block
    \ifx\@authorinfo\@undefined
      \null
    \else
      \ifx\f@rmat b\relax\begin{multicols}{2}\fi
      \@authorinfo
      \ifx\f@rmat b\relax\end{multicols}\fi
    \fi
    \par\vfill
    \ifx\f@rmat b\relax\begin{multicols}{2}\fi
    \par\vskip\baselineskip
    \ifx\@isbn\@undefined
    \else
      ISBN\space\@isbn\\
    \fi
    \ifx\@eisbnpdf\@undefined
    \else
      e-ISBN (PDF)\space\@eisbnpdf\\
    \fi
    \ifx\@eisbnepub\@undefined
    \else
      e-ISBN (EPUB)\space\@eisbnepub\\
    \fi
    \ifx\@setisbn\@undefined
    \else
      Set-ISBN\space\@setisbn\\
    \fi
    \ifx\@issn\@undefined
    \else
      ISSN\space\@issn\\
    \fi
    \vskip\baselineskip
    \ifx\@openaccess\relax
      \includegraphics[height=5mm]{by-nc-nd}%
      \par
      \vskip2\p@ % 13\p@ between the bottom of logo and the baseline of the following text
      \bookopenaccess@text
      \par
      \vskip\baselineskip
    \fi
    \ifcip
      \textbf{Library of Congress Cataloging-in-Publication Data}%
      \par
      A CIP catalog record for this book has been applied
        for at the Library of Congress.%
    \else
      \textbf{Library of Congress Control Number: \PCN}%
    \fi
    \par
    \vskip\baselineskip
    \iflanguage{ngerman}
     {\textbf{Bibliografische Information der Deutschen Nationalbibliothek}\break
      Die Deutsche Nationalbibliothek verzeichnet diese Publikation in der
      Deutschen Nationalbibliografie; detaillierte bibliografische Daten sind
      im Internet \"uber\break \url{http://dnb.dnb.de} abrufbar.}
     {\textbf{Bibliographic information published by the Deutsche Nationalbibliothek}\break
      The Deutsche Nationalbibliothek lists this publication in the
      Deutsche Nationalbibliografie;\break detailed bibliographic data are
      available on the Internet at \url{http://dnb.dnb.de}.}%
    \par
    \vskip\baselineskip
    \ifx\f@rmat b\relax\columnbreak\fi
    \book@copyrighttext
    \par
    \ifx\@openaccess\relax
      \iflanguage{ngerman}
        {Dieses Buch ist als Open-Access-Publikation verfügbar über \url{www.degruyter.com}.}
        {The book is published with open access at \url{www.degruyter.com}.}%
      \par
    \fi
    \ifx\@typesetter\@undefined
    \else
      \iflanguage{ngerman}
        {Satz}
        {Typesetting}%
        :\space\@typesetter
        \par
    \fi
    \ifx\@printbind\@undefined
    \else
      \iflanguage{ngerman}
        {Druck und Bindung}
        {Printing and binding}%
        :\space\@printbind
        \par
    \fi
    \ifx\@cover\@undefined
    \else
      \iflanguage{ngerman}
        {Coverabbildung}
        {Cover image}%
      :\space\@cover
      \par
    \fi
    \ifx\dgf@nts\relax
      \ifx\f@encoding\tu@encoding
        \char"267E%
      \else
        {\fontencoding{TS1}\selectfont\char"C9}%
      \fi
    \else
      \textcircled{\raise0.4ex\hbox{\fontsize{4}{4}\selectfont$\infty$}}%
    \fi
    \
    \iflanguage{ngerman}
      {Gedruckt auf s\"aurefreiem Papier}
      {Printed on acid-free paper}%
    \par
    Printed in Germany%
    \par
    \vskip\baselineskip
    \url{www.degruyter.com}%
    \par
    \ifx\f@rmat b\relax\end{multicols}\fi
  \egroup
  \check@copyrightpage@lastpage
  \if@tempswa
    \twocolumn
  \else
    \break
  \fi
  }

\def\check@copyrightpage@lastpage{%
  \ifdefined\pagefour@addressblocktype
    %% retain current addressblocktype
    \write\@mainaux{\string\gdef\string\pagefour@addressblocktype{\pagefour@addressblocktype}}%
  \else
    %% define multicols addressblocktype
    \ifnum\the\c@page>4\relax
      \write\@mainaux{\string\gdef\string\pagefour@addressblocktype{multicols}}%
    \fi
  \fi
  }

%% p. IV author/address block
\def\print@page@four@address@block{%
  \bgroup
    \DeclareRobustCommand\ead[2][]{{%
      \setkeys{ead}{label={},email,##1}%
      \@setead{\ead@id}{options}{##1}%
      \@setead{\ead@id}{type}{\ead@type}%
      \@setead{\ead@id}{value}{##2}%
      \@ifundefined{addressblock\@currentaddressblock ead@ids}
        {%
          \csxdef{addressblock\@currentaddressblock ead@ids}{\ead@id}%
        }{%
          \csxappto{addressblock\@currentaddressblock ead@ids}{,\ead@id}%
        }%
      }\ignorespaces}%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\author{%
        \@ifstar
         {\let\cor@author\relax\dg@auth@r}
         {\let\cor@author\@undefined\dg@auth@r}}%
      \let\editor\author
      \setcounter{dgauthor}{0}%
      \let\dg@auth@r\@undefined
      \newcommand\dg@auth@r[2][]{%
        \stepcounter{dgauthor}%
        \edef\dg@temp{\the\c@dgauthor}%
        \csdef{author\the\c@dgauthor}{%
          \edef\@currentaddressblock{####1}%
          ####2%
          }%
        }%
      \setcounter{dgaffil}{0}%
      \let\affil\undefined
      \newcommand\affil[2][]{%
        \stepcounter{dgaffil}%
        \edef\dg@temp{\the\c@dgaffil}%
        \csdef{affil\the\c@dgaffil}{####2}%
        }%
      ##3%
      }%
    \the\document@authorgroup
    \the\document@editorgroup
    \page@four@address@block@fmt
  \egroup
  }
\newcounter{currentauthor}
\newdimen\page@four@address@block@colwidth
\newdimen\page@four@address@block@colsep
\page@four@address@block@colsep=5mm
\def\set@pagefour@addressblocktype{%
  \ifdefined\pagefour@addressblocktype
  \else
    \def\pagefour@addressblocktype{vertical}%
  \fi
  }
\def\page@four@address@block@fmt{%
  \set@pagefour@addressblocktype
  \csuse{page@four@address@block@fmt@\pagefour@addressblocktype}%
  }%
\def\page@four@address@block@fmt@multicols{%
  \setcounter{currentauthor}{0}%
  \let\@ead@prefix@fmt\@gobble
  \textbf{\page@four@address@block@title}%
  \par
  \raggedcolumns
  \begin{multicols}{2}%
    \@whilenum\c@currentauthor<\c@dgauthor\do{%
      \stepcounter{currentauthor}%
      \vtop{% vtop used in order to prevent author-block breaking in {multicols}
        \raggedright
        \csname author\the\c@currentauthor\endcsname\par
        \csname affil\@currentaddressblock\endcsname\par
        \ifcsname addressblock\@currentaddressblock ead@ids\endcsname
          \expandafter\printead\expandafter{\csname addressblock\@currentaddressblock ead@ids\endcsname}%
          \global\csundef{addressblock\@currentaddressblock ead@ids}%
        \fi
        }%
      \par
      \vskip\baselineskip
      }%
  \end{multicols}%
  \par
  \nointerlineskip
  \vskip\baselineskip
  }
\def\page@four@address@block@fmt@vertical{%
  \setcounter{currentauthor}{0}%
  \def\@ead@prefix@fmt##1{\par}%
  \textbf{\page@four@address@block@title}%
  \par
  \raggedcolumns
  \@whilenum\c@currentauthor<\c@dgauthor\do{%
    \stepcounter{currentauthor}%
    \vtop{% vtop used in order to prevent author-block breaking in {multicols}
      \raggedright
      \csname author\the\c@currentauthor\endcsname\par
      \csname affil\@currentaddressblock\endcsname\par
      \ifcsname addressblock\@currentaddressblock ead@ids\endcsname
        \expandafter\printead\expandafter{\csname addressblock\@currentaddressblock ead@ids\endcsname}%
        \global\csundef{addressblock\@currentaddressblock ead@ids}%
      \fi
      }%
    \par
    \vskip\baselineskip
    }%
  \par
  \nointerlineskip
  \vskip\baselineskip
  }
\def\page@four@address@block@fmt@parbox{%
  \page@four@address@block@colwidth=\dimexpr(\textwidth-\page@four@address@block@colsep)/2\relax
  \setcounter{currentauthor}{0}%
  \let\@ead@prefix@fmt\@gobble
  \textbf{\page@four@address@block@title}%
  \par
  \@whilenum\c@currentauthor<\c@dgauthor\do{%
    \stepcounter{currentauthor}%
    \parbox[t]{\page@four@address@block@colwidth}{%
      \raggedright
      \csname author\the\c@currentauthor\endcsname\par
      \csname affil\@currentaddressblock\endcsname\par
      \ifcsname addressblock\@currentaddressblock ead@ids\endcsname
        \expandafter\printead\expandafter{\csname addressblock\@currentaddressblock ead@ids\endcsname}%
        \global\csundef{addressblock\@currentaddressblock ead@ids}%
      \fi
      }%
    \ifodd\the\c@currentauthor
      \ifnum\c@currentauthor=\c@dgauthor
      \else
        \hskip\page@four@address@block@colsep
      \fi
    \else
      \par
      \nointerlineskip
      \vskip\baselineskip
    \fi
    }%
  \par
  \nointerlineskip
  \vskip\baselineskip
  }
\def\page@four@address@block@title{%
  \bgroup
  \ifnum\c@dgauthor>\@ne
    \def\title@form{plural}%
  \else
    \def\title@form{singular}%
  \fi
  \if@editedbook
    \def\group@title{editorgroup}%
  \else
    \def\group@title{authorgroup}%
  \fi
  \csname\languagename @\title@form @page@four@\group@title @title\endcsname
  \egroup
  }
\def\english@singular@page@four@authorgroup@title{Author}
\def\english@plural@page@four@authorgroup@title{Authors}
\def\ngerman@singular@page@four@authorgroup@title{Autor}
\def\ngerman@plural@page@four@authorgroup@title{Autoren}
\def\english@singular@page@four@editorgroup@title{Editor}
\def\english@plural@page@four@editorgroup@title{Editors}
\def\ngerman@singular@page@four@editorgroup@title{Editor}
\def\ngerman@plural@page@four@editorgroup@title{Editors}

%% Dedication
\long\def\dedication#1{%
  \if@openright
    \cleardoublepage
  \else
    \clearpage
  \fi
  \dg@barpage{}{{\normalsize#1}}%
  }

%% DOI suffix for FM elements starts with 201
\def\setfmdoisuffix{%
  \setcounter{pseudochapter}{200}%
  }

%% Booknotes
\def\booknotes@title{%
  \csname\languagename @booknotes@title\endcsname
  }
\def\english@booknotes@title{???}
\def\ngerman@booknotes@title{???}
\define@key{booknotes}{title}{\def\booknotes@title{#1}}
\newenvironment{booknotes}[1][]%
  {%
    \@pseudochaptertrue
    \setkeys{booknotes}{#1}%
    \chapter*{\booknotes@title}%
  }{%
    \par
  }

%% bookmisc
\let\bookmisc@type\relax
\define@key{bookmisc}{type}{\def\bookmisc@type{#1}}
\define@key{bookmisc}{title}{\def\bookmisc@title{#1}}
\define@key{bookmisc}{chaptertitle}{\def\bookmisc@chaptertitle{#1}}
\newenvironment{bookmisc}[1][]%
  {%
    \@pseudochaptertrue
    \setkeys{bookmisc}{#1}%
    \csname process@\bookmisc@type\endcsname
    \ifdefined\bookmisc@chaptertitle
      \chapter*{\bookmisc@chaptertitle}%
    \fi
    \ifdefined\bookmisc@title
      \section*{\bookmisc@title}%
    \fi
  }{%
    \par
  }

%% Preface
\def\preface@title{%
  \csname\languagename @preface@title\endcsname
  }
\def\english@preface@title{Preface}
\def\ngerman@preface@title{Vorwort}
\define@key{preface}{title}{\def\preface@title{#1}}
\newenvironment{preface}[1][]%
  {%
    \@pseudochaptertrue
    \setkeys{preface}{#1}%
    \chapter*{\preface@title}%
  }{%
    \par
  }

%% Book Acknowledgment
\def\bookacknowledgement@title{%
  \csname\languagename @bookacknowledgement@title\endcsname
  }
\def\english@bookacknowledgement@title{Acknowledgement}
\def\ngerman@bookacknowledgement@title{???}
\define@key{bookacknowledgement}{title}{\def\bookacknowledgement@title{#1}}
\newenvironment{bookacknowledgement}[1][]%
  {%
    \@pseudochaptertrue
    \setkeys{bookacknowledgement}{#1}%
    \chapter*{\bookacknowledgement@title}%
  }{%
    \par
  }

%% List of Contributors
\def\loc@title{%
  \csname\languagename @loc@title\endcsname
  }
\def\english@loc@title{List of Contributors}
\def\ngerman@preface@title{???}
\define@key{loc}{title}{\def\loc@title{#1}}
\setpkgattr{loc}{font}{\sffamily\small}
\newenvironment{loc}[1][]%
  {%
    \setkeys{loc}{#1}%
    \chapter*{\loc@title}%
    \loc@font
  }{%
    \par
  }

%% page II Series Editor Group
\newtoks\document@serieseditorgroup
\get@env@toks{serieseditorgroup}{\document@serieseditorgroup}
\def\serieseditorgroup@sectionfmt#1{%
  \ifnum\jobstart@date@info<20180126
    \textbf{#1}%
  \else
    #1
  \fi
  }
\newcounter{serieseditorgroup}
\def\print@page@two@serieseditorgroup{%
  \bgroup
    \let\editor\@undefined
    \let\affil\@undefined
    \newcommand\editor[2][]{##2}%
    \newcommand\affil[2][]{##2}%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\serieseditorgroup@section{##2}%
      \ifdefined\@serieseditorgroup
        \vskip\baselineskip
      \fi
      \ifnum\jobstart@date@info<20180126\relax
      \else
        \normalfont\fontsize{14}{17}\selectfont\sffamily
      \fi
      \serieseditorgroup@sectionfmt{\serieseditorgroup@section}%
      \par
      ##3%
      \gdef\@serieseditorgroup{1}%
      }%
    \the\document@serieseditorgroup\par
  \egroup
  }

%% page III Editor Group
\def\editorgroup@sectionfmt#1{%
  #1%
  }
\def\page@three@editorgroup@font{%
  \fontsize{14}{17}\selectfont
  }
\def\print@page@three@editorgroup{%
  \bgroup
    \def\ead##1##{\@gobble}%
    \let\prefix\@gobble
    \def\editor{%
      \@ifstar
       {\let\cor@author\relax\dg@auth@r}
       {\let\cor@author\@undefined\dg@auth@r}}%
    \setcounter{dgauthor}{0}%
    \newcommand\dg@auth@r[2][]{%
      \stepcounter{dgauthor}%
      \xdef\number@of@authors{\the\c@dgauthor}%
      \csdef{author\the\c@dgauthor}{%
        ##2%
        }%
      \ifx\author@block@list\relax
        \cseappto{author@block@list}{author\the\c@dgauthor}%
      \else
        \cseappto{author@block@list}{,author\the\c@dgauthor}%
      \fi
      \ignorespaces
      }%
    \newcommand\affil[2][]{}%
    \setcounter{dgauthor}{0}%
    \if@editedbook
      \@ifundefined{book@editors}
        {\global\let\book@editors\temp@authors}
        {}%
    \fi
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\editorgroup@section{##2}%
      ##3%
      }%
    \the\document@editorgroup
    \page@three@editorgroup@fmt
  \egroup
  }

\def\page@three@editorgroup@fmt{%
  \let\author@prefix\@empty
  \let\temp@editors\@empty
  \setcounter{temp@author@cnt}{0}%
  \def\do##1{%
    \stepcounter{temp@author@cnt}%
    \ifnum\c@temp@author@cnt>\@ne
      \ifnum\c@temp@author@cnt=\number@of@authors
        \ifnum\number@of@authors=\tw@
          \def\author@prefix{\book@twoeditorsep}%
        \else
          \def\author@prefix{, and\space}%
        \fi
      \else
        \def\author@prefix{,\space}%
      \fi
    \fi
    \cseappto{temp@editors}{%
      \author@prefix
      \ignorespaces
      \csuse{##1}%
      }%
    }%
  \expandafter\docsvlist\expandafter{\author@block@list}%
  \let\page@three@editors\temp@editors
  \page@three@editorgroup@font
  \editorgroup@sectionfmt{\editorgroup@section}%
  \par
  \page@three@editors
  }

\newif\if@firstkwd
\def\print@page@four@bookkeywords{%
  \bgroup
    \def\kwd@sep{\unskip, }%
    \newcommand\kwd[2][]{%
      \bgroup
        \def\@tempa{##1}%
        \if@firstkwd
          \global\@firstkwdfalse
          \let\kwd@sep\@empty
        \fi
        \ifx\@tempa\@empty
          \kwd@sep
        \else
          \@tempa
        \fi
        ##2%
      \egroup
      \ignorespaces
      }%
    \long\def\start@tex@env##1[##2]##3\end@tex@env{%
      \def\@tempa{##2}%
      \ifx\@tempa\@empty
        \def\keywords@prefix{\textbf{\keywordsname}}%
      \else
        \def\keywords@prefix{\textbf{##2}}%
      \fi
      \@firstkwdtrue
      \keywords@prefix\par
      ##3%
      }%
    \the\document@bookkeywords
  \egroup
  }
%% <<< Book frontmatter <<<

%% >>> Index >>>
\RequirePackage{multicol}

\def\keya{\@ifnextchar[\@keya{\@keya[]}}
\def\keyb{\@ifnextchar[\@keyb{\@keyb[]}}
\def\keyk{\@ifnextchar[\@keyk{\@keyk[]}}
\def\keyc{\@ifnextchar[\@keyc{\@keyc[]}}
\def\keyl{\@ifnextchar[\@keyl{\@keyl[]}}
\def\keym{\@ifnextchar[\@keym{\@keym[]}}
\def\@keya[#1]#2#3{\@@keya{#2}{#3}}
\def\@keyb[#1]#2#3#4{\@@keyb{#2}{#3}{#4}}
\def\@keyk[#1]#2#3#4{\@@keyk{#2}{#3}{#4}}
\def\@keyc[#1]#2#3#4#5{\@@keyc{#2}{#3}{#4}{#5}}
\def\@keyl[#1]#2#3#4#5{\@@keyl{#2}{#3}{#4}{#5}}
\def\@keym[#1]#2#3#4#5{\@@keym{#2}{#3}{#4}{#5}}
\def\Letterskip#1{\indexspace}
\def\Letter#1{\bigskip\noindent\textbf{#1}}%
\def\P#1{#1}%

\mathchardef\specialpenalty=10001
\def\idx@fff#1{#1}
%% item
\gdef\@@keya#1#2{%
 \item \idx@fff{#1\hskip0.5em #2}%
 }
%% subitem
\gdef\@@keyb#1#2#3{%
 \subitem \idx@fff{#2\hskip0.25em #3}%
 }

%% subsubitem
\gdef\@@keyc#1#2#3#4{%
  \subsubitem \idx@fff{#3\hskip0.25em #4}%
 }

%% item + subitem
\gdef\@@keyk#1#2#3{%
 \item \idx@fff{#1}%
 \par
 \subitem \idx@fff{#2\hskip0.25em #3}%
}

 %% item + subitem + subsubitem
\gdef\@@keyl#1#2#3#4{
 \item \idx@fff{#1}%
 \par
 \subitem  \idx@fff{#2}%
 \par
 \subsubitem \idx@fff{#3\hskip0.25em #4}%
}

%% subitem + subsubitem
\gdef\@@keym#1#2#3#4{%
 \subitem  \idx@fff{#2}%
 \par
 \subsubitem \idx@fff{#3\hskip0.25em #4}%
}

\let\indexpreamble\@empty
\newenvironment{Theindex}
  {%
    \if@twocolumn
      \@restonecolfalse
    \else
      \@restonecoltrue
    \fi
    \parindent\z@
    \sffamily\mathversion{ss}\small
    \begin{multicols}{2}%
      [\chapter*{\indexname}%
       \indexpreamble]%
    \markboth{\indexname}{\indexname}%
    \raggedright
    \parskip\z@ \@plus .3\p@\relax
    \columnseprule \z@
    \let\item\@idxitem
  }{%
    \end{multicols}%
    \if@restonecol\onecolumn\fi
  }

\renewcommand\@idxitem{\par\let\idxlevel=\@ne\hangindent6mm}
\renewcommand\subitem{\par
  \ifx\idxlevel\@ne\let\idxlevel=\tw@\nopagebreak\fi
  \hangindent6mm\leavevmode\hskip0.5\p@\hb@xt@0.75em{\textendash\hss}}
\renewcommand\subsubitem{\par
  \ifx\idxlevel\tw@\let\idxlevel=\thr@@\nopagebreak\fi
  \hangindent6mm\leavevmode\hskip0.5\p@\hb@xt@1.5em{\kern0.75em\textendash\hss}}
\renewcommand\indexspace{\par\vskip11\p@\@plus5\p@\@minus3\p@\relax}
\columnsep4mm

\RequirePackage{texsort}
\providecommand*{\seealso}[2]{\emph{\alsoname} #1}
\providecommand*\alsoname{see also}
%% <<< Index <<<

%% >>> Table of Contents >>>
\renewenvironment{tableofcontents}{%
  \cleardoublepage
  \ifx\f@rmat b\else
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
  \fi
  \thispagestyle{plain}%
  \@afterindentfalse
  %% Do not include TOC entry for TOC itself
  \nocontentsline
  \chapter*{\contentsname}%
  %% Include TOC in bookmarks manually
  \Hy@writebookmark{}{\contentsname}{\@currentHref}{0}{toc}%
  \markboth{\contentsname}{\contentsname}%
  \let\lastentry@author\relax
  }{%
    \ifx\f@rmat b\else\if@restonecol\twocolumn\fi\fi
  }

%% TOC font setup
\ifnum\bookstart@date@info>20170705\relax
  \setpkgattr{tocauthor}{sep}{,\space}
  \setpkgattr{tocauthor}{font}{\sffamily\mdseries\normalsize}
  \setpkgattr{tocpagenumber}{font}{\bfseries\sffamily}
  \setpkgattr{tocnumberline}{font}{\sffamily\addfontfeature{Numbers=Monospaced}}
  \setpkgattr{toc-1level}{font}{\sffamily\bfseries\mathversion{ssbold}\large}
  \setpkgattr{toc0level}{font}{\sffamily\bfseries\mathversion{ssbold}}
  \setpkgattr{toc1level}{font}{\sffamily\mathversion{ss}}
  \setpkgattr{toc2level}{font}{\sffamily\mathversion{ss}}
  \setpkgattr{toc3level}{font}{\sffamily\mathversion{ss}}
\else
  \setpkgattr{tocauthor}{sep}{,\space}
  \setpkgattr{tocauthor}{font}{\sffamily\mdseries\normalsize}
  \setpkgattr{tocpagenumber}{font}{\bfseries}
  \setpkgattr{tocnumberline}{font}{\sffamily\addfontfeature{Numbers=Monospaced}}
  \setpkgattr{toc0level}{font}{\bfseries\mathversion{ssbold}}
  \setpkgattr{toc1level}{font}{}
  \setpkgattr{toc2level}{font}{}
  \setpkgattr{toc3level}{font}{}
\fi

%% TOC setup
\def\l@part{\@dottedtocline{-1}{24\p@}{}}
\def\l@chapter{\@dottedtocline{0}{13\p@}{}}
\def\l@schapter{\@dottedtocline{0}{13\p@}{\leftskip\z@}}
\def\l@section{\@dottedtocline{1}{\z@}{}}
\def\l@starsection{\@dottedtocline{1}{\z@}{}}
\def\l@subsection{\@dottedtocline{2}{\z@}{}}
\def\l@starsubsection{\@dottedtocline{2}{\z@}{}}
\def\l@subsubsection{\@dottedtocline{3}{\z@}{}}
\def\l@starsubsubsection{\@dottedtocline{3}{\z@}{}}
\def\l@paragraph{\@dottedtocline{4}{\z@}{}}
\def\l@subparagraph{\@dottedtocline{5}{\z@}{}}
\def\l@author#1#2{%
  %% count authors
  \bgroup
    \setcounter{temp@author@cnt}{0}%
    \def\author##1{%
      \stepcounter{temp@author@cnt}%
      }%
    #1%
    \xdef\number@of@toc@authors{\the\c@temp@author@cnt}%
  \egroup
  \vskip13\p@
  \bgroup
    \raggedright
    \toc@author@fmt{#1}%
    \par
  \egroup
  \let\lastentry@author\relax
  }
\def\l@figure{\@dottedtocline{1}{\z@}{}}

\def\toc@author@fmt#1{%
  \setcounter{temp@author@cnt}{0}%
  \let\author@prefix\relax
  \def\author##1{%
    \stepcounter{temp@author@cnt}%
    \ifnum\c@temp@author@cnt>\@ne
      \ifnum\c@temp@author@cnt=\number@of@toc@authors
        \ifnum\number@of@toc@authors=\tw@
          \def\author@prefix{ and\space}%
        \else
          \def\author@prefix{, and\space}%
        \fi
      \else
        \def\author@prefix{,\space}%
      \fi
    \fi
    \author@prefix
    ##1%
    }%
  \tocauthor@font
  #1%
  }

\def\@dottedtocline#1#2#3#4#5{%
  %\ifnum #1>\c@tocdepth %% since we explicitly define which levels should be printed in *.tex file (book-aux-toc)
  %\else
    \ifx\lastentry@author\@undefined
      \vskip#2\@plus.2\p@
    \fi
    \bgroup
      \parindent\z@
      \raggedright
      \@afterindenttrue
      \interlinepenalty\@M
      \leavevmode
      \ifnum#1=\m@ne\@tempdima12mm\relax
      \else
        \ifnum\c@tocdepth=\z@\@tempdima6mm\else\@tempdima12mm\fi
        \ifnum#1>\z@\advance\@tempdima6mm\fi
      \fi
      \leftskip\@tempdima\relax
      #3%overwriting style
      \null\nobreak\hskip-\leftskip
      \bgroup
        \csuse{toc#1level@font}%
        #4%
      \egroup
      \ifnum#1<\z@
      \else
        \nobreakspace
        {\small\dg@barone}%
        \nobreak\space
        {\tocpagenumber@font #5}%
      \fi%
      \par
    \egroup
    \let\lastentry@author\@undefined
  %\fi
  }
\DeclareRobustCommand*\numberline[1]{%
  \hb@xt@\@tempdima{%
    \bgroup
      \edef\DGMetaScience@figurealign{T}%
      \tocnumberline@font
      #1%
    \egroup
    \hfil
    }%
  }
%% <<< Table of Contents <<<

%% >>> List of Figures >>>
\setpkgattr{lof}{font}{\small}
\renewcommand\listoffigures{%
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  \chapter*{\listfigurename}%
  \markboth{\listfigurename}{\listfigurename}%
  \bgroup
    \lof@font
    \inserttoc{lof}%
  \egroup
  \if@restonecol\twocolumn\fi
  }
%% <<< List of Figures <<<

%% >>> List of Tables >>>
\setpkgattr{lot}{font}{\small}
\renewcommand\listoftables{%
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse
  \fi
  \chapter*{\listtablename}%
  \markboth{\listtablename}{\listtablename}%
  \bgroup
    \lot@font
    \inserttoc{lot}%
  \egroup
  \if@restonecol\twocolumn\fi
  }
%% <<< List of Tables <<<

\setpkgattr{epigraph}{font}{\itshape}
\setpkgattr{epigraphauthor}{font}{\upshape}
\ifnum\bookstart@date@info>20171017\relax
  \newenvironment{epigraph}
    {%
      \def\author##1{%
        \gdef\epigraph@author{%
          \epigraphauthor@font
          ##1%
          }%
        }%
      \small
      \list{}{}%
        \epigraph@font
        \item\relax
    }{%
      \unskip
      \item\epigraph@author
      \endlist
    }
\else
  \newenvironment{epigraph}
    {%
      \def\author##1{%
        \gdef\epigraph@author{%
          \epigraphauthor@font
          ##1
          }%
        }%
      \small
      \list{}{}%
        \raggedleft
        \epigraph@font
        \item\relax
    }{%
      \unskip
      \vskip\baselineskip
      \item\epigraph@author
      \endlist
    }
\fi

\def\pdfstringdefPreHookUnicode{%
  %%  Greek letters
  \def\alpha{\83\261}%
  \def\beta{\83\262}%
  \def\gamma{\83\263}%
  \def\delta{\83\264}%
  \def\epsilon{\83\265}%
  \def\zeta{\83\266}%
  \def\eta{\83\267}%
  \def\theta{\83\270}%ok
  \def\iota{\83\271}%
  \def\kappa{\83\272}%ok
  \def\lambda{\83\273}%ok
  \def\mu{\83\274}%
  \def\nu{\83\275}%
  \def\xi{\83\276}%
  \def\omicron{\83\276}%
  \def\pi{\83\300}%
  \def\rho{\83\301}%
  \def\sigma{\83\303}%
  \def\tau{\83\304}%
  \def\upsilon{\83\305}%
  \def\phi{\83\306}%
  \def\chi{\83\307}%
  \def\psi{\83\310}%
  \def\omega{\83\311}%
  %% Capital greek letters
  \def\Alpha{\83\221}%
  \def\Beta{\83\222}%
  \def\Gamma{\83\223}%
  \def\Delta{\83\224}%
  \def\Epsilon{\83\225}%
  \def\Zeta{\83\226}%
  \def\Eta{\83\227}%
  \def\Theta{\83\230}%ok
  \def\Iota{\83\231}%
  \def\Kappa{\83\232}%ok
  \def\Lambda{\83\233}%ok
  \def\Mu{\83\234}%
  \def\Nu{\83\235}%
  \def\Xi{\83\236}%
  \def\omicron{\83\236}%
  \def\Pi{\83\240}%
  \def\Rho{\83\241}%
  \def\Sigma{\83\243}%
  \def\Tau{\83\244}%
  \def\Upsilon{\83\245}%
  \def\Phi{\83\246}%
  \def\Chi{\83\247}%
  \def\Psi{\83\250}%
  \def\Omega{\83\251}%
  %% Var greek symbols
  \def\varrho{\83\361}%ok
  \let\varRho\rho%ok
  \def\varsigma{\83\302}%
  \let\varSigma\Sigma%
  \def\varphi{\83\325}%
  \let\varPhi\Phi%
  \def\varepsilon{\83\265}%
  \let\varEpsilon\Epsilon%
  \def\varpi{\83\326}%
  \let\varPi\Pi%
  \let\textalpha\alpha
  \def\varkappa{\83\360}%
  \let\varKappa\Kappa%
  \def\varBeta{\83\320}%
  \let\vargamma\gamma%
  \let\varGamma\Gamma%
  \def\vartheta{\83\321}%ok
  \def\varTheta{\83\364}%ok
  \let\vardelta\delta%
  \let\varDelta\Delta%
  \let\varlambda\lambda%
  \let\varLambda\Lambda%
  \let\varxi\xi%
  \let\varXi\Xi%
  \let\upsilon\upsilon%
  \let\varUpsilon\Upsilon%
  \let\varpsi\psi%
  \let\varPsi\Psi%
  \let\varomega\omega%
  \let\varOmega\Omega%
  \def\partial{\042\002}%
  \def\nabla{\042\007}%
  \def\in{\042\010}%
  \def\subset{\000\040\042\202\000\040}%
  \def\sum{\042\021}%
  \def\prod{\042\017}%
  \def\approx{\042\110}%
  \def\bigwedge{\042\300}%
  \def\nmid{\042\044}%
  \def\infty{\042\036}%
  \def\downarrow{\041\223}%
  \def\times{\000\327}%
  \def\otimes{\042\227}%
  \def\sim{\000\176}%
  \def\perp{\042\245}%
  \def\triangle{\045\263}%
  \def\equiv{\042\141}%
  \def\cap{\042\302}%
  \def\oplus{\042\225}%
  \let\bigoplus\oplus
  \def\sqrt{\042\032}%
  \def\cup{\042\052}%
  \let\bigcup\cup
  \def\int{\042\053}%
  \def\subseteq{\042\206}%
  \def\CYRSH{\004\050}%
  \def\therefore{\042\064}%
  \def\lfloor{\043\012}%
  \def\rfloor{\043\013}%
  \def\exists{\042\003}%
  \def\simeq{\042\103}%
  \def\forall{\042\000}%
  \def\succsim{\042\367}%
  \let\pnabla\nabla
  \def\sqcup{\042\224}%
  \def\preccurlyeq{\042\174}%
  \def\llbracket{\047\346}%
  \def\rrbracket{\047\346}%
  \def\vdash{\042\242}%
  \def\flat{\046\155}%
  \def\ell{\041\023}%
  }
\appto\pdfstringdefPreHook{%
  \ifHy@unicode
    \pdfstringdefPreHookUnicode
  \fi
  }

%% >>> startlocaldefs, endlocaldefs >>>
\let\startlocaldefs\makeatletter
\let\endlocaldefs\makeatother
%% definitions execution after \begin{document} (for tex4ht)
\ifdefined\HCode
  {
  \catcode`#=12\relax
  \catcode`&=6\relax
  \gdef\startlocaldefs{%
    \catcode`#=12\relax
    \makeatletter
    \@startlocaldefs
    }
  \gdef\@startlocaldefs@toks{}%
  \long\gdef\@startlocaldefs&1\endlocaldefs{%
    \long\xdef\@startlocaldefs@toks{\detokenize{&1}}%
    \makeatother
    \catcode`#=6\relax
    }
  }
  \appto\document{\makeatletter\expandafter\scantokens\expandafter{\@startlocaldefs@toks}\makeatother}%
\fi
%% <<< startlocaldefs, endlocaldefs <<<

%% >>> multiref >>>
\def\@first@of@all#1#2\end@first@of@all{#1}
\@ifundefined{@active@frmodefalse}{\newif\if@active@frmode}{}
\def\setmultiref@@hook#1{%
  \ifdefined\refout@write
    \refout@write{#1}%
  \fi
  }

\def\multiref@list@fmt#1#2{%
 \expandafter\process@by@dash #2--\end
  }
\def\process@by@dash #1--#2\end{%
  \def\@tempa{#1}%
  \def\@tempb{#2}%
  \let\temp@sep\relax
  \ifx\@tempa\@empty
  \else
    \def\do##1{%
      \csletcs{this@ref}{labelof@##1}%
      \ifdefined\this@ref
      \else
        \def\this@ref{??}%
      \fi
      \temp@sep
      \expandafter\ref\expandafter{\this@ref}%
      \def\temp@sep{\multiref@sep}%
      }%
    \expandafter\docsvlist\expandafter{\@tempa}%
  \fi
  \ifx\@tempb\@empty
  \else
    \multiref@multisep
    \process@by@dash #2\end
  \fi
  }

\RequirePackage{string}
\def\multiref@info@list{}
\let\multiref@@cons\@cons
\DeclareRobustCommand\multiref@with@debug[2][]{%
  \ifvmode\leavevmode\fi
  \bgroup
    \if@active@frmode
      \@active@frmodefalse\let\@restore@french\@active@frmodetrue
    \else
      \def\@restore@french{}%
    \fi
    \do@option@list{multiref}{prefix={},sep={, },multisep={--},braces={{}{}},text={},font={\@firstofone}}%
    \do@option@list{multiref}{#1}%
    \xdef\multiref@ref@prefix{\expandafter\@firstoftwo\multiref@braces}%
    \xdef\multiref@ref@postfix{\expandafter\@secondoftwo\multiref@braces}%
    \gdef\multiref@firstref{}\def\@a@{}\let\ref@sep\relax%
    \@for\@@refb:=#2\do{%
      \ifx\relax\ref@sep\relax
        \def\ref@sep{,}\xdef\multiref@firstref{\@@refb}%
      \else
        \expandafter\g@addto@macro\expandafter\@a@\expandafter{\ref@sep}%
      \fi
      \expandafter\setmultiref@@hook\expandafter{\@@refb}%
      \@ifundefined{r@\@@refb}{%
        \protect\G@refundefinedtrue
        \@latex@warning{Reference `\@@refb' on page \thepage \space undefined}%
        \g@addto@macro\@a@{??}%
        }{%
          \expandafter\expandafter\expandafter\expandafter\expandafter\expandafter\expandafter
          \def
          \expandafter\expandafter\expandafter\expandafter\expandafter\expandafter\expandafter
          \curr@ref@value
          \expandafter\expandafter\expandafter\expandafter\expandafter\expandafter\expandafter
          {\expandafter\expandafter\expandafter\@first@of@all\csname r@\@@refb\endcsname\end@first@of@all}%
          \csxdef{labelof@\curr@ref@value}{\@@refb}%
          \expandafter\g@addto@macro\expandafter\@a@\expandafter{\curr@ref@value}%
         }%
      }%
    \expandafter\compress@string@list\expandafter{\@a@}\to{multiref@@list}\sep{\multiref@ref@postfix\multiref@sep
      \multiref@ref@prefix}{\multiref@ref@postfix\multiref@multisep\multiref@ref@prefix}%
    \edef\multiref@@@list{\multiref@ref@prefix\multiref@@list\multiref@ref@postfix}%
    \def\multiref@list{}\let\ref@sep\relax
    \expandafter\@for\expandafter\@@refb\expandafter:\expandafter=\multiref@@@list
      \do{\ifx\relax\ref@sep\relax
            \def\ref@sep{,}%
          \else
            \expandafter\g@addto@macro\expandafter\multiref@list\expandafter{\ref@sep}%
          \fi
          \edef\temp@var{\multiref@ref@prefix0\multiref@ref@postfix}%
          \ifx\@@refb\temp@var
            \g@addto@macro\multiref@list{??}%
          \else
            \expandafter\g@addto@macro\expandafter\multiref@list\expandafter{\@@refb}%
          \fi
         }%
    \let\compressed@multiref@list\multiref@list
    \long\gdef\long@empty{}%
    \ifx\multiref@text\long@empty
    \else
      \global\let\multiref@list\multiref@text
    \fi
    \multiref@@cons\multiref@info@list{{options={\detokenize{[#1]}}, labels={\detokenize{#2}},
           inputline={\number\inputlineno},
           refs={\expandafter\detokenize\expandafter{\@a@}},
           compressed={\expandafter\detokenize\expandafter{\compressed@multiref@list}},
           output={\expandafter\expandafter\expandafter\detokenize
                   \expandafter\expandafter\expandafter{\expandafter\multiref@prefix\multiref@list}}}%
           }%
    \@restore@french
  \egroup
  \ifx\multiref@text\long@empty
    \expandafter\multiref@list@fmt\expandafter
      {\multiref@firstref}{\multiref@list}%
  \else
    \multiref@list
  \fi
  }
\let\multiref\multiref@with@debug
%% <<< multiref <<<

%% >>> no indent after [h], [h!] type float >>>
\appto\@addtocurcol{%
  \check@indent@after@float
  }
\appto\@addtotoporbot{%
  \def\no@check@indent@after@float{1}%
  }
\appto\@addtobot{%
  \def\no@check@indent@after@float{1}%
  }
\appto\@addtonextcol{%
  \def\no@check@indent@after@float{1}%
  }
\def\check@indent@after@float{%
  \global\let\noindent@after@float\@undefined
  \global\let\maybe@noindent@after@float\@undefined
  \ifdefined\no@check@indent@after@float
  \else
    \if@insert
      \gdef\noindent@after@float{1}%
    \else
      \gdef\maybe@noindent@after@float{1}%
    \fi
  \fi
  }

\def\end@float{%
  \@endfloatbox
  \xdef\last@float@id{\@captype\the\csname c@\@captype\endcsname}%
  \vtexsavepos\last@float@id
  \ifnum\@floatpenalty <\z@
    \@largefloatcheck
    \@cons\@currlist\@currbox
    \ifnum\@floatpenalty <-\@Mii
      \penalty -\@Miv
      \@tempdima\prevdepth
      \vbox{}%
      \prevdepth\@tempdima
      \penalty\@floatpenalty
    \else
      \vadjust{\penalty -\@Miv \vbox{}\penalty\@floatpenalty}%
      \@Esphack
    \fi
  \fi
  \check@indent@by@fps
  }

\ifnum\bookstart@date@info>20171018\relax
  \def\check@indent@by@fps{%
    \edef\h@fps{\detokenize{h}}%
    \edef\hh@fps{\detokenize{h!}}%
    \ifx\@fps\h@fps
      \aftergroup\check@and@remove@indent
    \else
      \ifx\@fps\hh@fps
        \aftergroup\check@and@remove@indent
      \fi
    \fi
    }
\else
  \let\check@indent@by@fps\relax
\fi
\RequirePackage{vtexsavepos}
\DeclareRobustCommand\vtexsavepos[1]{%
  %\quitvmode
  \pdfsavepos
  \global\let\vtexsavepos@pdf\relax
  \if@filesw
    \expandafter\expandafter\expandafter\write\expandafter\expandafter\expandafter\@posfile
    \expandafter\expandafter\expandafter{\expandafter\expandafter\expandafter\vtexsavepos@pdf
    \expandafter\expandafter\expandafter{#1\expandafter}%
    \expandafter{\number\pdflastxpos sp}{\number\pdflastypos sp}{\number\c@page}}%
  \fi
  }
\appto\@floatboxreset{%
  \xdef\current@captype{\@captype}%
  }
\def\check@and@remove@indent{%
  \everypar{%
    \if@nobreak
      \@nobreakfalse
      \clubpenalty \@M
      \if@afterindent \else
        {\setbox\z@\lastbox}%
      \fi
      \everypar{}%
    \else
      \clubpenalty \@clubpenalty
      \ifdefined\noindent@after@float
        \setbox\z@\lastbox
      \else
        \ifdefined\maybe@noindent@after@float
          \xdef\last@float@after@id{\current@captype\the\csname c@\current@captype\endcsname after}%
          \vtexsavepos\last@float@after@id
          \@@vtexpos\last@float@id
          \edef\float@page{\pagepos}%
          \@@vtexpos\last@float@after@id
          \edef\current@xpos{\xpos}%
          \edef\current@page{\pagepos}%
          \edef\parindent@xpos{\the\dimexpr 17.07164pt\relax}% 6mm standard \parindent
          \ifnum\current@page>\float@page
            %% experimental hack
            \ifdim\current@xpos=\parindent@xpos
              \hskip-\the\parindent
            \fi
          \fi
        \fi
      \fi
      \global\everypar{}%
    \fi
    }%
  }
%% <<< no indent after [h], [h!] type float <<<

%% \nn (noindent) control
\def\nn{%
  \noindent
  \if@pdfdraft
    \rlap{%
      {\hskip-50\p@ {\color{red} noindent}}%
      }%
  \fi
  }

\AtBeginDocument{%
  \def\htpicture@ext{.jpg}%
  }

\def\make@ix@page@void{%
  \gdef\voidpage{1}%
  \gdef\idx@default{idx:ind:voidpage}%
  }

\robustify{\,}
\robustify{\mbox}

\RequirePackage{xchpdfcomment}
\definecolor{Red}{cmyk}{0,1,1,0}
\def\xchtextcolor{Red}

\AtBeginDocument{%
  \ifnum\doc@stage>200\relax
    \protected\def\xch#1#2{\textcolor{black}{#1}}%
  \fi
  }

\RequirePackage{eqfix}

\endinput
%%
%% End of file `dgbook.cls'.
