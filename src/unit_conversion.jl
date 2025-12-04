"""
    convert_to_si!(ds)
    convert_to_si!(ds, ds164)

Converts the units of the given UFF dataset `ds` to SI units in place.
Note that the mass is defined as F/a and its units will be determined by F & a

**Input**
- `ds`: A vector of UFF datasets that contains dimensional data to be converted.
- `ds164`: A Dataset164 object that provides conversion factors (default: Dataset164() with SI units).

**Notes**

convert_to_si!(ds) reads the last encountered 164 dataset and uses its conversion factors for converting subsequent datasets.

convert_to_si!(ds, ds164) provides the conversion factors directly. Worth to use when `ds` does not contain a `Dataset164` or when using broadcasting.

**Output**
- `ds`: Dataset with its data converted to SI units.
"""
function convert_to_si!(datasets::Vector{UFFDataset}, ds164::Dataset164 = Dataset164())
    for ds in datasets
        if replace(string(ds.type), "Dataset" => "") in supported_datasets()
            convert_to_si!(ds, ds164)
        else
            @warn "File type $(ds.type) not support for unit conversions"
        end
    end
end

function convert_to_si!(ds::Dataset15, ds164::Dataset164)
    ds.node_coords ./= ds164.conversion_length
end

function convert_to_si!(ds::Dataset18, ds164::Dataset164)
    ds.cs_origin ./= ds164.conversion_length
    ds.cs_x ./= ds164.conversion_length
    ds.cs_xz ./= ds164.conversion_length
end

function convert_to_si!(ds::Dataset82, ds164::Dataset164) end

function convert_to_si!(ds::Dataset151, ds164::Dataset164) end

function convert_to_si!(ds::Dataset55, ds164::Dataset164)
    # Convert data vector
    # Implemented for  data types 8, 11, 12, 9, 13, 15

    factor = 1.

    # Data Type
    if any(ds.spec_dtype .== (0, 1))
        factor /= 1.
    elseif any(ds.spec_dtype .== (8, 11, 12))
        factor /= ds164.conversion_length
    elseif any(ds.spec_dtype .== (4, 9))
        factor /= ds164.conversion_force
    elseif any(ds.spec_dtype .== (2, 15))
        factor /= (ds164.conversion_force/ds164.conversion_length^2)
    else
        @warn "Conversion factor for $(ds.spec_dtype) not implemented, please submit PR"
    end

    ds.data .*= factor
end

function convert_to_si!(ds::Dataset58, ds164::Dataset164)
    # Convert data vector
    # Implemented for ordinate data types 8, 11, 12, 9, 13, 15

    # z-axis unit conversion not implemented
    # if abscissa has odd units then complain
    if any(ds.abs_spec_dtype .== (2, 3, 5, 6, 8, 9, 11, 12, 13, 15, 16))
        @warn "Unit Conversion not implemented for abscissa"
    end

    # Ordinate Numerator
    factor_num = 1.
    if any(ds.ord_spec_dtype .== (0, 1))
        factor_num /= 1.
    elseif any(ds.ord_spec_dtype .== (8, 11, 12))
        factor_num /= ds164.conversion_length
    elseif any(ds.ord_spec_dtype .== (9, 13))
        factor_num /= ds164.conversion_force
    elseif any(ds.ord_spec_dtype .== (15))
        factor_num /= (ds164.conversion_force/ds164.conversion_length^2)
    else
        @warn "Conversion factor for $(ds.ord_spec_dtype) not implemented, please submit PR"
    end

    # Ordinate Denominator
    factor_denom = 1.
    if any(ds.ord_denom_spec_dtype .== (0, 1))
        factor_denom /= 1.
    elseif any(ds.ord_denom_spec_dtype .== (8, 11, 12))
        factor_denom /= ds164.conversion_length
    elseif any(ds.ord_denom_spec_dtype .== (9, 13))
        factor_denom /= ds164.conversion_force
    elseif any(ds.ord_denom_spec_dtype .== (15))
        factor_denom /= (ds164.conversion_force/ds164.conversion_length^2)
    else
        @warn "Conversion factor for $(ds.ord_denom_spec_dtype) not implemented, please submit PR"
    end

    ds.data .*= (factor_num / factor_denom)
end

function convert_to_si!(ds::Dataset164, ds164::Dataset164)
    if ds === ds164
        return
    end

    @warn "A Dataset164 was encountered during unit conversion. Overriding the current values with the new ones."
    ds164.units = ds.units
    ds164.description = ds.description
    ds164.temperature_mode = ds.temperature_mode
    ds164.conversion_length = ds.conversion_length
    ds164.conversion_force = ds.conversion_force
    ds164.conversion_temperature = ds.conversion_temperature
    ds164.conversion_temperature_offset = ds.conversion_temperature_offset
end

function convert_to_si!(ds::Dataset1858, ds164::Dataset164) end

function convert_to_si!(ds::Dataset2411, ds164::Dataset164)
    ds.node_coords ./= ds164.conversion_length
end

function convert_to_si!(ds::Dataset2412, ds164::Dataset164) end

function convert_to_si!(ds::Dataset2414, ds164::Dataset164)
    # To Do

    @warn "Not yet implemented"
end