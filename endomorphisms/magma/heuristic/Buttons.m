/***
 *  Some useful functions
 *
 *  Copyright (C) 2016-2017
 *            Edgar Costa      (edgarcosta@math.dartmouth.edu)
 *            Davide Lombardo  (davide.lombardo@unipi.it)
 *            Jeroen Sijsling  (jeroen.sijsling@uni-ulm.de)
 *
 *  See LICENSE.txt for license details.
 */


intrinsic CurveExtra(X::Crv : prec := 100) -> .
{This converts a curve to be over a NumberFieldExtra if it is not given in that way.}

assert ISA(Type(X), Crv);
F := BaseRing(X);
if Type(F) eq RngInt then
    X := ChangeRing(X, Rationals());
    F := BaseRing(X);
end if;
if assigned F`base then
    return X;
end if;

if IsQQ(F) then
    K := RationalsExtra(prec);
    h := hom< F -> K | >;
    return ChangeRingCurve(X, h);
end if;

K := NumberFieldExtra(DefiningPolynomial(F) : prec := 100);
test, h := IsIsomorphic(F, K);
assert test;
return ChangeRingCurve(X, h);

end intrinsic;


intrinsic HeuristicEndomorphismAlgebra(X::. : Geometric := false, CC := false, UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns the abstract endomorphism algebra of the Jacobian of X, by default over the base and over QQbar if Geometric is set to true. If CC is set to true, the algebra over QQbar is determined without performing any further algebraization. Notational conventions are specified in the documentation folder.}

assert ISA(Type(X), Crv);
X := CurveExtra(X);
if CC then
    Geometric := true;
    GeoEndoRep := GeometricEndomorphismRepresentationCC(X);
else
    GeoEndoRep := GeometricEndomorphismRepresentation(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
end if;

if Geometric then
    EndoAlg, EndoDesc := EndomorphismStructure(GeoEndoRep);
    return EndoDesc, EndoAlg[1], EndoAlg[2];
end if;
if not assigned X`base_endo_rep then
    F, h := InclusionOfBaseExtra(BaseRing(GeoEndoRep[1][1]));
    X`base_endo_rep := EndomorphismRepresentation(GeoEndoRep, F, h);
end if;
EndoAlg, EndoDesc := EndomorphismStructure(X`base_endo_rep);
/* Description, algebra, ring */
return EndoDesc, EndoAlg[1], EndoAlg[2];

end intrinsic;


intrinsic HeuristicEndomorphismRepresentation(X::. : Geometric := false, CC := false, UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns the endomorphism representation of X the Jacobian of X, by default over the base and over QQbar if Geometric is set to true. If CC is set to true, then no algebraization occurs. Notational conventions are specified in the documentation folder.}

assert ISA(Type(X),Crv);
X := CurveExtra(X);
if CC then
    Geometric := true;
    GeoEndoRep := GeometricEndomorphismRepresentationCC(X);
else
    GeoEndoRep := GeometricEndomorphismRepresentation(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
end if;

if Geometric then
    return GeoEndoRep;
end if;
if not assigned X`base_endo_rep then
    F, h := InclusionOfBaseExtra(BaseRing(GeoEndoRep[1][1]));
    X`base_endo_rep := EndomorphismRepresentation(GeoEndoRep, F, h);
end if;
return X`base_endo_rep;

end intrinsic;


intrinsic HeuristicEndomorphismFieldOfDefinition(X::. : UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns the field of definition of the endomorphism algebra of the Jacobian of X.}

assert ISA(Type(X), Crv);
X := CurveExtra(X);
GeoEndoRep := GeometricEndomorphismRepresentation(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
return BaseRing(GeoEndoRep[1][1]);

end intrinsic;


intrinsic HeuristicEndomorphismLattice(X::. : UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns an encoded description of the endomorphism lattice of the Jacobian of X.}

assert ISA(Type(X), Crv);
X := CurveExtra(X);
GeoEndoRep := GeometricEndomorphismRepresentation(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
return EndomorphismLattice(GeoEndoRep);

end intrinsic;


intrinsic HeuristicIsGL2(X::. : Definition := "Generalized", UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns whether or not the Jacobian of X is of GL_2-type in the generalized sense (by default) or in the sense of Ribet (if Definition is set to "Ribet").}

assert ISA(Type(X), Crv);
assert Definition in [ "Generalized", "Ribet" ];
X := CurveExtra(X); g := Genus(X);
if Definition eq "Generalized" then
    desc, A := HeuristicEndomorphismAlgebra(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
    if not Dimension(A) eq g then
        return false;
    end if;
    return Center(A) eq A;
elif Definition eq "Ribet" then
    desc, A := HeuristicEndomorphismAlgebra(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
    if not Dimension(A) eq g then
        return false;
    end if;
    if not Center(A) eq A then
        return false;
    end if;
    return #CentralIdempotents(A) eq 1;
end if;

end intrinsic;


intrinsic HeuristicDecomposition(X::. : UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns a description of the decomposition of the Jacobian of X. The first entry describes the isotypical field, the second entry describes the decomposition field and whether this field is minimal, the third entry describes decomposition over the base (dimensions and powers followed by equations), and the fourth entry describes the decomposition over the decomposition field (dimensions and powers followed by equations).}

assert ISA(Type(X),Crv);
X := CurveExtra(X);
/* Precompute, setting parameters here */
EndoRep := HeuristicEndomorphismRepresentation(X : UpperBound := UpperBound, DegreeDivides := DegreeDivides);
decbase, decbaseeqs := DecompositionOverBase(X);
Kiso := IsotypicalField(X); Kdec, _, test := FullDecompositionField(X);
decgeo, decgeoeqs, identsgeo := DecompositionOverClosure(X);
return [* Kiso, [* Kdec, test *], [* decbase, decbaseeqs *], [* decgeo, decgeoeqs, identsgeo *] *];

end intrinsic;


intrinsic EndRROverQQbar(X::.) -> .
{Returns a description of End_RR (Jac (Xbar)). This is a list of tuples [ <n, d> ], a single factor of which corresponds to a factor of Mat_n (A_d), where A_d is the unique skew field over RR of dimension d. So for example [ <1, 1>, <2, 4> ] would correspond to the real algebra RR x M_2 (HH).}

EndoDesc := HeuristicEndomorphismAlgebra(X : CC := true);
return EndoDesc[1];

end intrinsic;


intrinsic EndRROverQQ(X::. : UpperBound := 16, DegreeDivides := Infinity()) -> .
{Returns a description of End_RR (Jac (Xbar)). This is a list of tuples [ <n, d> ], a single factor of which corresponds to a factor of Mat_n (A_d), where A_d is the unique skew field over RR of dimension d. So for example [ <1, 1>, <2, 4> ] would correspond to the real algebra RR x M_2 (HH).}

EndoDesc := HeuristicEndomorphismAlgebra(X : UpperBound := 16, DegreeDivides := Infinity());
return EndoDesc[1];

end intrinsic;


/* THE INTRINSICS FROM THIS POINT ONWARD ARE NOT YET SUPPORTED */

// TODO: This function needs an overhaul */
intrinsic HeuristicDecompositionInformation(X::.) -> .
{Returns decomposition description. First entry describes isotypical field, second entry decomposition field, third entry whether this field is minimal, fourth entry describes decomposition over the base (dimensions and powers followed by equations), fifth entry describes decomposition over decomposition field (dimensions and powers followed by equations and identifications). For more, see the documentation on output.}

assert ISA(Type(X),Crv);
X := CurveExtra(X);
Kiso := IsotypicalField(X);
part1 := FieldDescriptionExtra(Kiso);

Kdec, _, test := FullDecompositionField(X);
part2 := FieldDescriptionExtra(Kdec);

if test then testint := 1; else testint := 0; end if;
part3 := testint;

decbase, decbaseeqs := DecompositionOverBase(X);
part41 := [ < fac[1], fac[2] > : fac in decbase ];
part42 := [ CurveDescription(fac)[3] : fac in decbaseeqs ];
part4 := < part41, part42 >;

decgeo, decgeoeqs := DecompositionOverClosure(X);
part51 := [ < fac[1], fac[2] > : fac in decgeo ];
part52 := [ CurveDescription(fac)[3] : fac in decgeoeqs ];
part5 := < part51, part52 >;

return < part1, part2, part3, part4, part5 >;

end intrinsic;


// TODO: This is terrible. It should have a base, geometric, and field version instead to clean this up.
//       After that, a second function can see if a genus 1 or 2 root factor comes from equation over base.
//       (Extension is too advanced to put here.)
//       Returns values should be field plus equations; it also needs a descriptive version.
intrinsic HeuristicJacobianFactors(X::. : AllIdems := true, AllPPs := false, ProjToIdem := true, ProjToPP := true) -> .
{Returns factors of the Jacobian of X over the smallest possible fields, together with maps to these factors. Setting AllMaps to true returns multiple entries for a given components in the decomposition together with all possible maps (instead of a single one). Setting AllPPs to true returns multiple entries for a given idempotent, corresponding to the various choices of principal polarization. Setting ProjToIdem to false uses an inclusion instead of a projection when taking idempotents. Setting ProjToPP to false uses an inclusion instead of a projection when making a period matrix principally polarized. If ProjToIdem and ProjToPP are not equal, then right now the algorithm only returns a component, not a corresponding map from or to the Jacobian of X.}

assert ISA(Type(X),Crv);
X := CurveExtra(X);
P := PeriodMatrix(X); gP := #Rows(P);
GeoEndoRep := GeometricEndomorphismRepresentation(X);

if not AllIdems and not AllPPs then
    comps := SplitComponents(P, GeoEndoRep : AllIdems := AllIdems, ProjToIdem := ProjToIdem);
    recs := [ ];
    for comp in comps do
        Q, mor := Explode(comp);
        if #Rows(Q) eq #Rows(P) then
            return [ [* X, [* IdentityMatrix(BaseRing(X), gP), IdentityMatrix(Rationals(), 2*gP) *] *] ];
        end if;
        rec := ReconstructionFromComponent(P, Q, mor : AllPPs := AllPPs, ProjToIdem := ProjToIdem, ProjToPP := ProjToPP);
        Append(~recs, rec);
    end for;
    return recs;

elif not AllIdems and AllPPs then
    comps := SplitComponents(P, GeoEndoRep : AllIdems := AllIdems, ProjToIdem := ProjToIdem);
    recss := [ ];
    for comp in comps do
        Q, mor := Explode(comp);
        if #Rows(Q) eq #Rows(P) then
            return [ [ [* X, [* IdentityMatrix(BaseRing(X), gP), IdentityMatrix(Rationals(), 2*gP) *] *] ] ];
        end if;
        recs := ReconstructionFromComponent(P, Q, mor : AllPPs := AllPPs, ProjToIdem := ProjToIdem, ProjToPP := ProjToPP);
        Append(~recss, recs);
    end for;
    return recss;

elif AllIdems and not AllPPs then
    comptups := SplitComponents(P, GeoEndoRep : AllIdems := AllIdems, ProjToIdem := ProjToIdem);
    recss := [ ];
    for comptup in comptups do
        recs := [ ];
        for comp in comptup do
            Q, mor := Explode(comp);
            if #Rows(Q) eq #Rows(P) then
                return [ [ [* X, [* IdentityMatrix(BaseRing(X), gP), IdentityMatrix(Rationals(), 2*gP) *] *] ] ];
            end if;
            rec := ReconstructionFromComponent(P, Q, mor : AllPPs := AllPPs, ProjToIdem := ProjToIdem, ProjToPP := ProjToPP);
            Append(~recs, rec);
        end for;
        Append(~recss, recs);
    end for;
    return recss;

elif AllIdems and AllPPs then
    comptups := SplitComponents(P, GeoEndoRep : AllIdems := AllIdems, ProjToIdem := ProjToIdem);
    recsss := [ ];
    for comptup in comptups do
        recss := [ ];
        for comp in comptup do
            Q, mor := Explode(comp);
            if #Rows(Q) eq #Rows(P) then
                return [ [ [ [* X, [* IdentityMatrix(BaseRing(X), gP), IdentityMatrix(Rationals(), 2*gP) *] *] ] ] ];
            end if;
            recs := ReconstructionFromComponent(P, Q, mor : AllPPs := AllPPs, ProjToIdem := ProjToIdem, ProjToPP := ProjToPP);
            Append(~recss, recs);
        end for;
        Append(~recsss, recss);
    end for;
    return recsss;
end if;

end intrinsic;


intrinsic IsogenyInformation(X::. : facinfo := 0) -> .
{Returns homology exponents of isogeny induced by splitting, and tests if it is compatible with the various polarizations. The information in facinfo has to be calculated with AllIdems set to true.}

assert ISA(Type(X),Crv);
X := CurveExtra(X);
if Type(facinfo) eq RngIntElt then
    facinfo := HeuristicJacobianFactors(X);
end if;

Rs := &cat[ [ fac[2][2] : fac in facs ] : facs in facinfo ];
gYs := [ #Rows(R) div 2 : R in Rs ];
gX := &+gYs;
EYs := [ StandardSymplecticMatrix(gY) : gY in gYs ];
EX := StandardSymplecticMatrix(gX);

T := VerticalJoin(Rs);
S := SmithForm(ChangeRing(T, Integers()));
D := Diagonal(S);
exps := [ d : d in D ];

EY := DiagonalJoin(EYs);
test := IsRationalMultiple(Transpose(T)*EY*T, EX);
degs := [ Abs((R*EX*Transpose(R))[1, 1 + (#Rows(R) div 2)]) : R in Rs ];

return exps, test, degs;

end intrinsic;


intrinsic CertifiedEndomorphismAlgebra(X::Crv : P0 := 0, Geometric := false, Al := "Cantor", Cheat := false) -> .
{Returns the (certified) endomorphism algebra of X using the base point P0 (if given), by default over the base and over QQbar if Geometric is set to true. The output is the same as for HeuristicEndomorphismAlgebra with the last argument the certificates. Al is either "Cantor" or "Divisor".}

assert ISA(Type(X),Crv);
X := CurveExtra(X);
F := BaseRing(X);
if IsHyperelliptic(X) and Cheat then
    f, h := HyperellipticPolynomials(X);
    g := 4*f + h^2;
    g /:= LeadingCoefficient(g);
    if IsEven(Degree(g)) then
        X := HyperellipticCurve(g);
    else
        R<x> := Parent(g);
        e := Degree(g) div 2;
        n := 0;
        repeat
            geven := Numerator(Evaluate(g, 1/(x - n)));
            geven /:= LeadingCoefficient(geven);
            n +:= 1;
        until Degree(geven) mod 2 eq 0;
        X := HyperellipticCurve(geven);
    end if;
end if;
vprint EndoFind : "";
vprint EndoFind : "Curve after transformation to standard form:";
vprint EndoFind : X;

GeoEndoRepCC := HeuristicEndomorphismRepresentation(X : Geometric := true, CC := true);
if not VerifySaturated(GeoEndoRepCC, X`period_matrix) then
    return false, "Not saturated";
end if;
EndoRep := HeuristicEndomorphismRepresentation(X : Geometric := Geometric);

fss := [* *];
for rep in EndoRep do
    test, fs := Correspondence(X, X, rep : P := P0, Q := P0, Al := Al);
    if not test then
        return false, rep;
    end if;
    Append(~fss, rep cat [* fs *]);
end for;
return true, fss;

end intrinsic;


function Humanize(desc);
/* Maketh ye stuffeth readable */

str := "";
alg := desc[2];
if #alg ne 1 then
    str cat:= "Isotypical factors of A:\n";
end if;
for fac in alg do
    m, dimD, pol, discD, dimA := Explode(fac);
    dimK := #pol - 1;
    assert (dimD mod dimK) eq 0;
    indDsq := dimD div dimK;
    test, indD := IsSquare(indDsq);
    assert test;

    if m gt 1 then
        str cat:= (Sprint(m) cat "th power of ");
    end if;
    str cat:= ("abelian variety of dimension " cat Sprint(dimA)) cat " ";
    str cat:= "with endomorphism algebra ";
    if indD ne 1 then
        str cat:= ("a division algebra of index " cat Sprint(indD) cat " and discriminant " cat Sprint(discD) cat " over ");
    end if;
    if #pol eq 2 then
        str cat:= "QQ\n";
    else
        R<t> := PolynomialRing(Rationals());
        str cat:= ("the number field defined by " cat Sprint(R ! pol)) cat "\n";
    end if;
end for;
return str;

end function;


intrinsic HeuristicEndomorphismDescription(X::. : Geometric := false, CC := false) -> .
{Returns an encoded description of the endomorphism algebra of X, by default over the base and over QQbar if Geometric is set to true. If CC is set to true, the algebra over QQbar is determined without performing any further algebraization.}

assert ISA(Type(X), Crv);
X := CurveExtra(X);
if CC then
    Geometric := true;
    GeoEndoRep := GeometricEndomorphismRepresentationCC(X);
else
    GeoEndoRep := GeometricEndomorphismRepresentation(X);
end if;

if Geometric then
    EndoAlg, EndoDesc := EndomorphismStructure(GeoEndoRep);
    return Humanize(EndoDesc);
end if;
if not assigned X`base_endo_rep then
    F, h := InclusionOfBaseExtra(BaseRing(GeoEndoRep[1][1]));
    X`base_endo_rep := EndomorphismRepresentation(GeoEndoRep, F, h);
end if;
EndoAlg, EndoDesc := EndomorphismStructure(X`base_endo_rep);
return Humanize(EndoDesc);

end intrinsic;


/* Functions from here on are deprecated and no longer supported */
intrinsic HeuristicEndomorphismRing(X::. : Geometric := false, CC := false) -> .
{Returns the abstract endomorphism algebra of X, by default over the base and over QQbar if Geometric is set to true. If CC is set to true, the algebra over QQbar is determined without performing any further algebraization.}

assert ISA(Type(X), Crv);
X := CurveExtra(X);
if CC then
    Geometric := true;
    GeoEndoRep := GeometricEndomorphismRepresentationCC(X);
else
    GeoEndoRep := GeometricEndomorphismRepresentation(X);
end if;

if Geometric then
    EndoAlg, EndoDesc := EndomorphismStructure(GeoEndoRep);
    return Order(Integers(), EndoAlg[2]);
end if;
if not assigned X`base_endo_rep then
    F, h := InclusionOfBaseExtra(BaseRing(GeoEndoRep[1][1]));
    X`base_endo_rep := EndomorphismRepresentation(GeoEndoRep, F, h);
end if;
EndoAlg, EndoDesc := EndomorphismStructure(X`base_endo_rep);
return Order(Integers(), EndoAlg[2]);

end intrinsic;
