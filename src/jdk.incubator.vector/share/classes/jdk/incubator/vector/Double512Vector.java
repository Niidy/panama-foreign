/*
 * Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have
 * questions.
 */
package jdk.incubator.vector;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Objects;
import jdk.internal.vm.annotation.ForceInline;
import static jdk.incubator.vector.VectorIntrinsics.*;

@SuppressWarnings("cast")
final class Double512Vector extends DoubleVector<Shapes.S512Bit> {
    static final Double512Species SPECIES = new Double512Species();

    static final Double512Vector ZERO = new Double512Vector();

    static final int LENGTH = SPECIES.length();

    private final double[] vec; // Don't access directly, use getElements() instead.

    private double[] getElements() {
        return VectorIntrinsics.maybeRebox(this).vec;
    }

    Double512Vector() {
        vec = new double[SPECIES.length()];
    }

    Double512Vector(double[] v) {
        vec = v;
    }

    @Override
    public int length() { return LENGTH; }

    // Unary operator

    @Override
    Double512Vector uOp(FUnOp f) {
        double[] vec = getElements();
        double[] res = new double[length()];
        for (int i = 0; i < length(); i++) {
            res[i] = f.apply(i, vec[i]);
        }
        return new Double512Vector(res);
    }

    @Override
    Double512Vector uOp(Mask<Double, Shapes.S512Bit> o, FUnOp f) {
        double[] vec = getElements();
        double[] res = new double[length()];
        boolean[] mbits = ((Double512Mask)o).getBits();
        for (int i = 0; i < length(); i++) {
            res[i] = mbits[i] ? f.apply(i, vec[i]) : vec[i];
        }
        return new Double512Vector(res);
    }

    // Binary operator

    @Override
    Double512Vector bOp(Vector<Double, Shapes.S512Bit> o, FBinOp f) {
        double[] res = new double[length()];
        double[] vec1 = this.getElements();
        double[] vec2 = ((Double512Vector)o).getElements();
        for (int i = 0; i < length(); i++) {
            res[i] = f.apply(i, vec1[i], vec2[i]);
        }
        return new Double512Vector(res);
    }

    @Override
    Double512Vector bOp(Vector<Double, Shapes.S512Bit> o1, Mask<Double, Shapes.S512Bit> o2, FBinOp f) {
        double[] res = new double[length()];
        double[] vec1 = this.getElements();
        double[] vec2 = ((Double512Vector)o1).getElements();
        boolean[] mbits = ((Double512Mask)o2).getBits();
        for (int i = 0; i < length(); i++) {
            res[i] = mbits[i] ? f.apply(i, vec1[i], vec2[i]) : vec1[i];
        }
        return new Double512Vector(res);
    }

    // Trinary operator

    @Override
    Double512Vector tOp(Vector<Double, Shapes.S512Bit> o1, Vector<Double, Shapes.S512Bit> o2, FTriOp f) {
        double[] res = new double[length()];
        double[] vec1 = this.getElements();
        double[] vec2 = ((Double512Vector)o1).getElements();
        double[] vec3 = ((Double512Vector)o2).getElements();
        for (int i = 0; i < length(); i++) {
            res[i] = f.apply(i, vec1[i], vec2[i], vec3[i]);
        }
        return new Double512Vector(res);
    }

    @Override
    Double512Vector tOp(Vector<Double, Shapes.S512Bit> o1, Vector<Double, Shapes.S512Bit> o2, Mask<Double, Shapes.S512Bit> o3, FTriOp f) {
        double[] res = new double[length()];
        double[] vec1 = getElements();
        double[] vec2 = ((Double512Vector)o1).getElements();
        double[] vec3 = ((Double512Vector)o2).getElements();
        boolean[] mbits = ((Double512Mask)o3).getBits();
        for (int i = 0; i < length(); i++) {
            res[i] = mbits[i] ? f.apply(i, vec1[i], vec2[i], vec3[i]) : vec1[i];
        }
        return new Double512Vector(res);
    }

    @Override
    double rOp(double v, FBinOp f) {
        double[] vec = getElements();
        for (int i = 0; i < length(); i++) {
            v = f.apply(i, v, vec[i]);
        }
        return v;
    }

    // Binary operations with scalars

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> add(double o) {
        return add(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> add(double o, Mask<Double,Shapes.S512Bit> m) {
        return add(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> addSaturate(double o) {
        return addSaturate(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> addSaturate(double o, Mask<Double,Shapes.S512Bit> m) {
        return addSaturate(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> sub(double o) {
        return sub(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> sub(double o, Mask<Double,Shapes.S512Bit> m) {
        return sub(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> subSaturate(double o) {
        return subSaturate(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> subSaturate(double o, Mask<Double,Shapes.S512Bit> m) {
        return subSaturate(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> mul(double o) {
        return mul(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> mul(double o, Mask<Double,Shapes.S512Bit> m) {
        return mul(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> div(double o) {
        return div(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> div(double o, Mask<Double,Shapes.S512Bit> m) {
        return div(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> min(double o) {
        return min(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> max(double o) {
        return max(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public Mask<Double, Shapes.S512Bit> equal(double o) {
        return equal(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public Mask<Double, Shapes.S512Bit> notEqual(double o) {
        return notEqual(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public Mask<Double, Shapes.S512Bit> lessThan(double o) {
        return lessThan(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public Mask<Double, Shapes.S512Bit> lessThanEq(double o) {
        return lessThanEq(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public Mask<Double, Shapes.S512Bit> greaterThan(double o) {
        return greaterThan(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public Mask<Double, Shapes.S512Bit> greaterThanEq(double o) {
        return greaterThanEq(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> blend(double o, Mask<Double,Shapes.S512Bit> m) {
        return blend(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> atan2(double o) {
        return atan2(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> atan2(double o, Mask<Double,Shapes.S512Bit> m) {
        return atan2(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> pow(double o) {
        return pow(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> pow(double o, Mask<Double,Shapes.S512Bit> m) {
        return pow(SPECIES.broadcast(o), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> fma(double o1, double o2) {
        return fma(SPECIES.broadcast(o1), SPECIES.broadcast(o2));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> fma(double o1, double o2, Mask<Double,Shapes.S512Bit> m) {
        return fma(SPECIES.broadcast(o1), SPECIES.broadcast(o2), m);
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> hypot(double o) {
        return hypot(SPECIES.broadcast(o));
    }

    @Override
    @ForceInline
    public DoubleVector<Shapes.S512Bit> hypot(double o, Mask<Double,Shapes.S512Bit> m) {
        return hypot(SPECIES.broadcast(o), m);
    }



    // Unary operations

    @Override
    @ForceInline
    public Double512Vector abs() {
        return (Double512Vector) VectorIntrinsics.unaryOp(
            VECTOR_OP_ABS, Double512Vector.class, double.class, LENGTH,
            this,
            v1 -> ((Double512Vector)v1).uOp((i, a) -> (double) Math.abs(a)));
    }

    @Override
    @ForceInline
    public Double512Vector neg() {
        return (Double512Vector) VectorIntrinsics.unaryOp(
            VECTOR_OP_NEG, Double512Vector.class, double.class, LENGTH,
            this,
            v1 -> ((Double512Vector)v1).uOp((i, a) -> (double) -a));
    }

    @Override
    @ForceInline
    public Double512Vector sqrt() {
        return (Double512Vector) VectorIntrinsics.unaryOp(
            VECTOR_OP_SQRT, Double512Vector.class, double.class, LENGTH,
            this,
            v1 -> ((Double512Vector)v1).uOp((i, a) -> (double) Math.sqrt((double) a)));
    }

    // Binary operations

    @Override
    @ForceInline
    public Double512Vector add(Vector<Double,Shapes.S512Bit> o) {
        Objects.requireNonNull(o);
        Double512Vector v = (Double512Vector)o;
        return (Double512Vector) VectorIntrinsics.binaryOp(
            VECTOR_OP_ADD, Double512Vector.class, double.class, LENGTH,
            this, v,
            (v1, v2) -> ((Double512Vector)v1).bOp(v2, (i, a, b) -> (double)(a + b)));
    }

    @Override
    @ForceInline
    public Double512Vector sub(Vector<Double,Shapes.S512Bit> o) {
        Objects.requireNonNull(o);
        Double512Vector v = (Double512Vector)o;
        return (Double512Vector) VectorIntrinsics.binaryOp(
            VECTOR_OP_SUB, Double512Vector.class, double.class, LENGTH,
            this, v,
            (v1, v2) -> ((Double512Vector)v1).bOp(v2, (i, a, b) -> (double)(a - b)));
    }

    @Override
    @ForceInline
    public Double512Vector mul(Vector<Double,Shapes.S512Bit> o) {
        Objects.requireNonNull(o);
        Double512Vector v = (Double512Vector)o;
        return (Double512Vector) VectorIntrinsics.binaryOp(
            VECTOR_OP_MUL, Double512Vector.class, double.class, LENGTH,
            this, v,
            (v1, v2) -> ((Double512Vector)v1).bOp(v2, (i, a, b) -> (double)(a * b)));
    }

    @Override
    @ForceInline
    public Double512Vector div(Vector<Double,Shapes.S512Bit> o) {
        Objects.requireNonNull(o);
        Double512Vector v = (Double512Vector)o;
        return (Double512Vector) VectorIntrinsics.binaryOp(
            VECTOR_OP_DIV, Double512Vector.class, double.class, LENGTH,
            this, v,
            (v1, v2) -> ((Double512Vector)v1).bOp(v2, (i, a, b) -> (double)(a / b)));
    }

    @Override
    @ForceInline
    public Double512Vector add(Vector<Double,Shapes.S512Bit> v, Mask<Double, Shapes.S512Bit> m) {
        // TODO: use better default impl: bOp(o, m, (i, a, b) -> (double)(a + b));
        return blend(add(v), m);
    }

    @Override
    @ForceInline
    public Double512Vector sub(Vector<Double,Shapes.S512Bit> v, Mask<Double, Shapes.S512Bit> m) {
        // TODO: use better default impl: bOp(o, m, (i, a, b) -> (double)(a - b));
        return blend(sub(v), m);
    }

    @Override
    @ForceInline
    public Double512Vector mul(Vector<Double,Shapes.S512Bit> v, Mask<Double, Shapes.S512Bit> m) {
        // TODO: use better default impl: bOp(o, m, (i, a, b) -> (double)(a * b));
        return blend(mul(v), m);
    }

    @Override
    @ForceInline
    public Double512Vector div(Vector<Double,Shapes.S512Bit> v, Mask<Double, Shapes.S512Bit> m) {
        // TODO: use better default impl: bOp(o, m, (i, a, b) -> (double)(a / b));
        return blend(div(v), m);
    }


    // Ternary operations

    @Override
    @ForceInline
    public Double512Vector fma(Vector<Double,Shapes.S512Bit> o1, Vector<Double,Shapes.S512Bit> o2) {
        Objects.requireNonNull(o1);
        Objects.requireNonNull(o2);
        Double512Vector v1 = (Double512Vector)o1;
        Double512Vector v2 = (Double512Vector)o2;
        return (Double512Vector) VectorIntrinsics.ternaryOp(
            VECTOR_OP_FMA, Double512Vector.class, double.class, LENGTH,
            this, v1, v2,
            (w1, w2, w3) -> w1.tOp(w2, w3, (i, a, b, c) -> Math.fma(a, b, c)));
    }

    // Type specific horizontal reductions

    @Override
    @ForceInline
    public double addAll() {
        long bits = (long) VectorIntrinsics.reductionCoerced(
                                VECTOR_OP_ADD, Double512Vector.class, double.class, LENGTH,
                                this,
                                v -> {
                                    double r = v.rOp((double) 0, (i, a, b) -> (double) (a + b));
                                    return (long)Double.doubleToLongBits(r);
                                });
        return Double.longBitsToDouble(bits);
    }

    @Override
    @ForceInline
    public double mulAll() {
        long bits = (long) VectorIntrinsics.reductionCoerced(
                                VECTOR_OP_MUL, Double512Vector.class, double.class, LENGTH,
                                this,
                                v -> {
                                    double r = v.rOp((double) 1, (i, a, b) -> (double) (a * b));
                                    return (long)Double.doubleToLongBits(r);
                                });
        return Double.longBitsToDouble(bits);
    }

    // Memory operations

    @Override
    @ForceInline
    public void intoArray(double[] a, int ix) {
        Objects.requireNonNull(a);
        ix = VectorIntrinsics.checkIndex(ix, a.length, LENGTH);
        VectorIntrinsics.store(Double512Vector.class, double.class, LENGTH,
                               a, ix, this,
                               (arr, idx, v) -> v.forEach((i, a_) -> ((double[])arr)[idx + i] = a_));
    }

    @Override
    @ForceInline
    public void intoArray(double[] a, int ax, Mask<Double, Shapes.S512Bit> m) {
        // TODO: use better default impl: forEach(m, (i, a_) -> a[ax + i] = a_);
        Double512Vector oldVal = SPECIES.fromArray(a, ax);
        Double512Vector newVal = oldVal.blend(this, m);
        newVal.intoArray(a, ax);
    }

    //

    @Override
    public String toString() {
        return Arrays.toString(getElements());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || this.getClass() != o.getClass()) return false;

        Double512Vector that = (Double512Vector) o;
        return Arrays.equals(this.getElements(), that.getElements());
    }

    @Override
    public int hashCode() {
        return Arrays.hashCode(vec);
    }

    // Binary test

    @Override
    Double512Mask bTest(Vector<Double, Shapes.S512Bit> o, FBinTest f) {
        double[] vec1 = getElements();
        double[] vec2 = ((Double512Vector)o).getElements();
        boolean[] bits = new boolean[length()];
        for (int i = 0; i < length(); i++){
            bits[i] = f.apply(i, vec1[i], vec2[i]);
        }
        return new Double512Mask(bits);
    }

    // Comparisons


    // Foreach

    @Override
    void forEach(FUnCon f) {
        double[] vec = getElements();
        for (int i = 0; i < length(); i++) {
            f.apply(i, vec[i]);
        }
    }

    @Override
    void forEach(Mask<Double, Shapes.S512Bit> o, FUnCon f) {
        boolean[] mbits = ((Double512Mask)o).getBits();
        forEach((i, a) -> {
            if (mbits[i]) { f.apply(i, a); }
        });
    }

    Long512Vector toBits() {
        double[] vec = getElements();
        long[] res = new long[this.species().length()];
        for(int i = 0; i < this.species().length(); i++){
            res[i] = Double.doubleToLongBits(vec[i]);
        }
        return new Long512Vector(res);
    }


    @Override
    public Double512Vector rotateEL(int j) {
        double[] vec = getElements();
        double[] res = new double[length()];
        for (int i = 0; i < length(); i++){
            res[j + i % length()] = vec[i];
        }
        return new Double512Vector(res);
    }

    @Override
    public Double512Vector rotateER(int j) {
        double[] vec = getElements();
        double[] res = new double[length()];
        for (int i = 0; i < length(); i++){
            int z = i - j;
            if(j < 0) {
                res[length() + z] = vec[i];
            } else {
                res[z] = vec[i];
            }
        }
        return new Double512Vector(res);
    }

    @Override
    public Double512Vector shiftEL(int j) {
        double[] vec = getElements();
        double[] res = new double[length()];
        for (int i = 0; i < length() - j; i++) {
            res[i] = vec[i + j];
        }
        return new Double512Vector(res);
    }

    @Override
    public Double512Vector shiftER(int j) {
        double[] vec = getElements();
        double[] res = new double[length()];
        for (int i = 0; i < length() - j; i++){
            res[i + j] = vec[i];
        }
        return new Double512Vector(res);
    }

    @Override
    public Double512Vector shuffle(Vector<Double, Shapes.S512Bit> o, Shuffle<Double, Shapes.S512Bit> s) {
        Double512Vector v = (Double512Vector) o;
        return uOp((i, a) -> {
            double[] vec = this.getElements();
            int e = s.getElement(i);
            if(e >= 0 && e < length()) {
                //from this
                return vec[e];
            } else if(e < length() * 2) {
                //from o
                return v.getElements()[e - length()];
            } else {
                throw new ArrayIndexOutOfBoundsException("Bad reordering for shuffle");
            }
        });
    }

    @Override
    public Double512Vector swizzle(Shuffle<Double, Shapes.S512Bit> s) {
        return uOp((i, a) -> {
            double[] vec = this.getElements();
            int e = s.getElement(i);
            if(e >= 0 && e < length()) {
                return vec[e];
            } else {
                throw new ArrayIndexOutOfBoundsException("Bad reordering for shuffle");
            }
        });
    }

    @Override
    @ForceInline
    public Double512Vector blend(Vector<Double, Shapes.S512Bit> o1, Mask<Double, Shapes.S512Bit> o2) {
        Objects.requireNonNull(o1);
        Objects.requireNonNull(o2);
        Double512Vector v = (Double512Vector)o1;
        Double512Mask   m = (Double512Mask)o2;

        return (Double512Vector) VectorIntrinsics.blend(
            Double512Vector.class, Double512Mask.class, double.class, LENGTH,
            this, v, m,
            (v1, v2, m_) -> v1.bOp(v2, (i, a, b) -> m_.getElement(i) ? b : a));
    }

    @Override
    @ForceInline
    @SuppressWarnings("unchecked")
    public <F> Vector<F, Shapes.S512Bit> rebracket(Class<F> type) {
        Objects.requireNonNull(type);
        // TODO: check proper element type
        return VectorIntrinsics.rebracket(
            Double512Vector.class, double.class, LENGTH,
            type, this,
            (v, t) -> (Vector<F, Shapes.S512Bit>) v.reshape(t, v.shape())
        );
    }

    @Override
    public <F, Z extends Shape> Vector<F, Z> cast(Class<F> type, Z shape) {
        Vector.Species<F,Z> species = Vector.speciesInstance(type, shape);

        // Whichever is larger
        int blen = Math.max(species.bitSize(), bitSize()) / Byte.SIZE;
        ByteBuffer bb = ByteBuffer.allocate(blen);

        int limit = Math.min(species.length(), length());

        double[] vec = getElements();
        if (type == Byte.class) {
            for (int i = 0; i < limit; i++){
                bb.put(i, (byte) vec[i]);
            }
        } else if (type == Short.class) {
            for (int i = 0; i < limit; i++){
                bb.asShortBuffer().put(i, (short) vec[i]);
            }
        } else if (type == Integer.class) {
            for (int i = 0; i < limit; i++){
                bb.asIntBuffer().put(i, (int) vec[i]);
            }
        } else if (type == Long.class){
            for (int i = 0; i < limit; i++){
                bb.asLongBuffer().put(i, (long) vec[i]);
            }
        } else if (type == Float.class){
            for (int i = 0; i < limit; i++){
                bb.asFloatBuffer().put(i, (float) vec[i]);
            }
        } else if (type == Double.class){
            for (int i = 0; i < limit; i++){
                bb.asDoubleBuffer().put(i, (double) vec[i]);
            }
        } else {
            throw new UnsupportedOperationException("Bad lane type for casting.");
        }

        return species.fromByteBuffer(bb);
    }

    // Accessors

    @Override
    public double get(int i) {
        double[] vec = getElements();
        return vec[i];
    }

    @Override
    public Double512Vector with(int i, double e) {
        double[] res = vec.clone();
        res[i] = e;
        return new Double512Vector(res);
    }

    // Mask

    static final class Double512Mask extends AbstractMask<Double, Shapes.S512Bit> {
        static final Double512Mask TRUE_MASK = new Double512Mask(true);
        static final Double512Mask FALSE_MASK = new Double512Mask(false);

        public Double512Mask(boolean[] bits) {
            super(bits);
        }

        public Double512Mask(boolean val) {
            super(val);
        }

        @Override
        Double512Mask uOp(MUnOp f) {
            boolean[] res = new boolean[species().length()];
            boolean[] bits = getBits();
            for (int i = 0; i < species().length(); i++) {
                res[i] = f.apply(i, bits[i]);
            }
            return new Double512Mask(res);
        }

        @Override
        Double512Mask bOp(Mask<Double, Shapes.S512Bit> o, MBinOp f) {
            boolean[] res = new boolean[species().length()];
            boolean[] bits = getBits();
            boolean[] mbits = ((Double512Mask)o).getBits();
            for (int i = 0; i < species().length(); i++) {
                res[i] = f.apply(i, bits[i], mbits[i]);
            }
            return new Double512Mask(res);
        }

        @Override
        public Double512Species species() {
            return SPECIES;
        }

        @Override
        public Double512Vector toVector() {
            double[] res = new double[species().length()];
            boolean[] bits = getBits();
            for (int i = 0; i < species().length(); i++) {
                res[i] = (double) (bits[i] ? -1 : 0);
            }
            return new Double512Vector(res);
        }

        @Override
        @ForceInline
        @SuppressWarnings("unchecked")
        public <Z> Mask<Z, Shapes.S512Bit> rebracket(Class<Z> type) {
            Objects.requireNonNull(type);
            // TODO: check proper element type
            return VectorIntrinsics.rebracket(
                Double512Mask.class, double.class, LENGTH,
                type, this,
                (m, t) -> (Mask<Z, Shapes.S512Bit>)m.reshape(t, m.species().shape())
            );
        }

        // Unary operations

        //Mask<E, S> not();

        // Binary operations

        @Override
        @ForceInline
        public Double512Mask and(Mask<Double,Shapes.S512Bit> o) {
            Objects.requireNonNull(o);
            Double512Mask m = (Double512Mask)o;
            return VectorIntrinsics.binaryOp(VECTOR_OP_AND, Double512Mask.class, long.class, LENGTH,
                                             this, m,
                                             (m1, m2) -> m1.bOp(m2, (i, a, b) -> a & b));
        }

        @Override
        @ForceInline
        public Double512Mask or(Mask<Double,Shapes.S512Bit> o) {
            Objects.requireNonNull(o);
            Double512Mask m = (Double512Mask)o;
            return VectorIntrinsics.binaryOp(VECTOR_OP_OR, Double512Mask.class, long.class, LENGTH,
                                             this, m,
                                             (m1, m2) -> m1.bOp(m2, (i, a, b) -> a | b));
        }

        // Reductions

        @Override
        @ForceInline
        public boolean anyTrue() {
            return VectorIntrinsics.test(COND_notZero, Double512Mask.class, long.class, LENGTH,
                                         this, this,
                                         (m1, m2) -> super.anyTrue());
        }

        @Override
        @ForceInline
        public boolean allTrue() {
            return VectorIntrinsics.test(COND_carrySet, Double512Mask.class, long.class, LENGTH,
                                         this, species().trueMask(),
                                         (m1, m2) -> super.allTrue());
        }
    }

    // Shuffle

    static final class Double512Shuffle extends AbstractShuffle<Double, Shapes.S512Bit> {
        static final IntVector.IntSpecies<Shapes.S512Bit> INT_SPECIES = (IntVector.IntSpecies<Shapes.S512Bit>) Vector.speciesInstance(Integer.class, Shapes.S_512_BIT);

        public Double512Shuffle(int[] reorder) {
            super(reorder);
        }

        @Override
        public Double512Species species() {
            return SPECIES;
        }

        @Override
        public IntVector.IntSpecies<Shapes.S512Bit> intSpecies() {
            return INT_SPECIES;
        }
    }

    // Species

    @Override
    public Double512Species species() {
        return SPECIES;
    }

    static final class Double512Species extends DoubleSpecies<Shapes.S512Bit> {
        static final int BIT_SIZE = Shapes.S_512_BIT.bitSize();

        static final int LENGTH = BIT_SIZE / Double.SIZE;

        @Override
        public String toString() {
           StringBuilder sb = new StringBuilder("Shape[");
           sb.append(bitSize()).append(" bits, ");
           sb.append(length()).append(" ").append(double.class.getSimpleName()).append("s x ");
           sb.append(elementSize()).append(" bits");
           sb.append("]");
           return sb.toString();
        }

        @Override
        public int bitSize() {
            return BIT_SIZE;
        }

        @Override
        public int length() {
            return LENGTH;
        }

        @Override
        public Class<Double> elementType() {
            return Double.class;
        }

        @Override
        public int elementSize() {
            return Double.SIZE;
        }

        @Override
        public Shapes.S512Bit shape() {
            return Shapes.S_512_BIT;
        }

        @Override
        Double512Vector op(FOp f) {
            double[] res = new double[length()];
            for (int i = 0; i < length(); i++) {
                res[i] = f.apply(i);
            }
            return new Double512Vector(res);
        }

        @Override
        Double512Vector op(Mask<Double, Shapes.S512Bit> o, FOp f) {
            double[] res = new double[length()];
            boolean[] mbits = ((Double512Mask)o).getBits();
            for (int i = 0; i < length(); i++) {
                if (mbits[i]) {
                    res[i] = f.apply(i);
                }
            }
            return new Double512Vector(res);
        }

        // Factories

        @Override
        public Double512Mask constantMask(boolean... bits) {
            return new Double512Mask(bits.clone());
        }

        @Override
        public Double512Shuffle constantShuffle(int... ixs) {
            return new Double512Shuffle(ixs);
        }

        @Override
        @ForceInline
        public Double512Vector zero() {
            return VectorIntrinsics.broadcastCoerced(Double512Vector.class, double.class, LENGTH,
                                                     Double.doubleToLongBits(0.0f),
                                                     (z -> ZERO));
        }

        @Override
        @ForceInline
        public Double512Vector broadcast(double e) {
            return VectorIntrinsics.broadcastCoerced(
                Double512Vector.class, double.class, LENGTH,
                Double.doubleToLongBits(e),
                ((long bits) -> SPECIES.op(i -> Double.longBitsToDouble((long)bits))));
        }

        @Override
        @ForceInline
        public Double512Mask trueMask() {
            return VectorIntrinsics.broadcastCoerced(Double512Mask.class, long.class, LENGTH,
                                                     (long)-1,
                                                     (z -> Double512Mask.TRUE_MASK));
        }

        @Override
        @ForceInline
        public Double512Mask falseMask() {
            return VectorIntrinsics.broadcastCoerced(Double512Mask.class, long.class, LENGTH,
                                                     0,
                                                     (z -> Double512Mask.FALSE_MASK));
        }

        @Override
        @ForceInline
        public Double512Vector fromArray(double[] a, int ix) {
            Objects.requireNonNull(a);
            ix = VectorIntrinsics.checkIndex(ix, a.length, LENGTH);
            return (Double512Vector) VectorIntrinsics.load(Double512Vector.class, double.class, LENGTH,
                                                        a, ix,
                                                        (arr, idx) -> super.fromArray((double[]) arr, idx));
        }

        @Override
        @ForceInline
        public Double512Vector fromArray(double[] a, int ax, Mask<Double, Shapes.S512Bit> m) {
            return zero().blend(fromArray(a, ax), m); // TODO: use better default impl: op(m, i -> a[ax + i]);
        }
    }
}
