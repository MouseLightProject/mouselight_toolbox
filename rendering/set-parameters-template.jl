const notify_addr = "$notifications_email_address"
const bill_userid = "mouselight"

const source="$tilebase_folder_path"  # path to (line-fixed-pointing!) tilebase.cache.yml
const destination="$octree_folder_path"  # path to octree

const file_infix="$file_infix"
const file_format_load="$file_format_load"  # "tif" or "h5"
const file_format_save="$file_format_save"  # "tif" or "h5"

const shared_scratch="$shared_scratch_folder_path"
const logfile_scratch="$log_scratch_folder_path"  # should be on /groups
const delete_scratch="as-you-go"   # "never", "at-end", or "as-you-go"

const voxelsize_um=[0.3, 0.3, 1]  # desired pixel size
# voxelsize_used_um, in destination/calculated_parameters.jl, is that actually used.
#   adjusted to make tile widths even and tile volume a multiple of 32*32*4,

const interpolation = "linear"  # "nearest" or "linear"

const downsample_from_existing_leaves=false

# build the octree with a function below.  should return UInt16

# 1. the simplest and fastest
#downsampling_function(arg::Array{UInt16,3}) = (@inbounds return arg[1,1,1])

# 2. equivalent to mean(arg) but 30x faster and half the memory
#downsampling_function(arg::Array{UInt16,3}) = UInt16(sum(arg)>>3)

# 3. 2nd brightest of the 8 pixels
# equivalent to sort(vec(arg))[7] but half the time and a third the memory usage
function downsampling_function(arg::Array{UInt16,3})
  m0::UInt16 = 0x0000
  m1::UInt16 = 0x0000
  for i = 1:8
    @inbounds tmp::UInt16 = arg[i]
    if tmp>m0
      m1=m0
      m0=tmp
    elseif tmp>m1
      m1=tmp
    end
  end
  m1
end

# 4. Nth brightest non-zero of the 8 pixels
#function downsampling_function(arg::Array{UInt16,3})
#  n=5
#  m = fill(0x0000,n)
#  for i = 1:8
#    @inbounds tmp::UInt16 = arg[i]
#    for i=1:n
#      if tmp>m[i]
#        m[i+1:n]=m[i:n-1]
#        m[i]=tmp
#        break
#      end
#    end
#  end
#  for i=n:-1:1
#    m[i]==0 || return m[i]
#  end
#  return 0x0000
#end


# normalized origin and shape of sub-bounding box to render
const region_of_interest=([0,0,0], [1,1,1])  # e.g. ([0,0.5,0], [0.5,0.5,0.5]) == octant three

# or use the following code to convert morton order to origin & shape
#morton_order = [8,1,7,3]
#const region_of_interest = (
#    dropdims(sum(
#        [(((morton_order[depth]-1)>>xyz)&1)/2^depth for xyz=0:2, depth=1:length(morton_order)] ,dims=2), dims=2),
#    fill(0.5^length(morton_order),3) )

const include_origins_outside_roi=false   # set to true to render all of small test ROI


const max_pixels_per_leaf=120e6  # maximum number of pixels in output tiles
const leaf_dim_divisible_by=8    # each dim of leafs should be divisible by this

const max_tilechannels_per_job=1800  # maximum number of input tiles * nchannels per cluster job
# larger is more efficient with file i/o; smaller is more parallel computation


const which_cluster = "janelia" # "janelia" or ["hostname1", "hostname2", "hostname3", ...]
const bad_nodes = []  # e.g. ["h09u20"]

const ncores_incluster = 48*32

const throttle_leaf_njobs = 64  # maximum number of jobs to use to render leafs
# for which_cluster=="janelia" set to 64 (max is ncores_incluster/leaf_ncores_per_job)
# otherwise this parameter is ignored, and is taken to be length(which_cluster)

const leaf_ncores_per_job = 16
# for which_cluster=="janelia" set based on memory and load utilization (max is 48)

const leaf_nthreads_per_process = 8  # should match barycentricCPU.c

const leaf_process_oversubscription = 2

const throttle_octree_njobs = 256  # maximum number of compute nodes to use to downsample octree
# for which_cluster=="janelia" set to 256 (max is ncores_incluster/octree_ncores_per_job)
# otherwise this parameter is ignored, and is taken to be length(which_cluster)

const throttle_octree_njobs_per_machine = min(8,Sys.CPU_THREADS)
# ignored when which_cluster=="janelia"
# otherwise set to ncores per machine for small data sets

const octree_ncores_per_job = 4
# for which_cluster=="janelia" set to 4 (max is 9)
# otherwise set to 1 for small data sets

const short_queue = false  # rendering MUST take less than 1 hour


const overall_time_limit = short_queue ? 60 : 4320  # three days
const leaf_time_limit    = short_queue ? 60 : 2880  # two days
const octree_time_limit  = 480   # eight hours
const cleanup_time_limit = 60    # one hour


# the below are for testing purposes.  users shouldn't need to change.
const dry_run = false
const use_avx = true
const peon_ram = 15*1024^3
const other_ram = (10+5)*1024^3   # system + manager
